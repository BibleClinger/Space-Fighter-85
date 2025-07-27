clear; text.column = 30; text.row = 15; text.color = color.white; print "Loading..."

import "mathUtil"
import "listUtil"
import "bclib"

import "variables"

// Basic state machine setup

eStates = bclib.Enum.Create("LOADING TITLE PREPLAYING PLAYING PAUSED GAMEOVER CLEARLEVELSCREEN WINSCREEN CUTSCENE")
eEvents = bclib.Enum.Create("DONE PAUSE STARTGAME ENDGAME CLEARLEVEL WIN")

states = {}

for s in eStates.names(true)
    states[eStates[s]] = bclib.Machine.State(eStates[s])
end for

// States transitions

states[eStates.LOADING].on(eEvents.DONE, eStates.TITLE)
states[eStates.TITLE].on(eEvents.STARTGAME, eStates.PREPLAYING)
states[eStates.PREPLAYING].on(eEvents.STARTGAME, eStates.PLAYING)
states[eStates.PLAYING].on(eEvents.PAUSE, eStates.PAUSED).on(eEvents.ENDGAME, eStates.GAMEOVER).on(eEvents.CLEARLEVEL, eStates.CLEARLEVELSCREEN)
states[eStates.CLEARLEVELSCREEN].on(eEvents.STARTGAME, eStates.PREPLAYING).on(eEvents.WIN, eStates.WINSCREEN)
states[eStates.PAUSED].on(eEvents.STARTGAME, eStates.PLAYING)
states[eStates.WINSCREEN].on(eEvents.DONE, eStates.TITLE)
states[eStates.GAMEOVER].on(eEvents.DONE, eStates.TITLE)

// State code implementation

states[eStates.LOADING].init = function(self)
    // game.initVariables // We do this on import now if "variables"
    game.clearLayers
end function

states[eStates.LOADING].enter = function(self)
    globals.gameLoaded = true
    text.column = 30; text.row = 15; text.color = color.white; print "Loaded... 100%"
end function

states[eStates.LOADING].tick = function(self, delta)
    if globals.gameLoaded then self.machine.raiseEvent(eEvents.DONE)
end function

states[eStates.LOADING].exit = function(self)
    text.clear
end function

// TITLE state

states[eStates.TITLE].init = function(self)
    self.centerLabel = bclib.TextLabel.Create({"row":game.SCREEN_TEXT_HEIGHT/2 + game.SCREEN_TEXT_HEIGHT/4, "column":game.SCREEN_TEXT_WIDTH/2, "justification":bclib.TextLabel.eJustificationType.CENTER})
    game.starManager = StarManager.Create(10, 50, game.starSpriteLayer)
end function

states[eStates.TITLE].enter = function(self)
    game.reset
    self.centerLabel.print "Space Fighter 85"
    game.sounds["title_music"].play game.musicVolume
end function

states[eStates.TITLE].tick = function(self, delta)
    game.starManager.tick delta
    if key.pressed("c") then self.machine.raiseEvent(eEvents.STARTGAME)
end function

states[eStates.TITLE].exit = function(self)
    self.centerLabel.clear
    game.sounds["title_music"].stop
end function

// PREPLAYING state

states[eStates.PREPLAYING].enter = function(self)
    self.machine.raiseEvent(eEvents.STARTGAME)
end function

// PLAYING state

states[eStates.PLAYING].init = function(self)

    onTimeout = function(timer)
        game.bCanCounter = true
    end function

    onNextWave = function(time)
        
    end function

    self.debugLabel = bclib.TextLabel.Create({"row":game.SCREEN_TEXT_HEIGHT-1, "column":game.SCREEN_TEXT_WIDTH/2, "justification":bclib.TextLabel.eJustificationType.CENTER})
    self.input = {}
    self.hud = HUD.Create(game.HUDLayer)
    self.lasers = [
        Laser.Create(color.blue, 150, {"x":0, "y":0}, {"x":game.SCREEN_WIDTH/2, "y":floor(game.SCREEN_HEIGHT/2 + game.SCREEN_HEIGHT/4)}, game.entitySpriteLayer),
        Laser.Create(color.red, 150, {"x":game.SCREEN_WIDTH, "y":0}, {"x":game.SCREEN_WIDTH/2, "y":floor(game.SCREEN_HEIGHT/2 + game.SCREEN_HEIGHT/4)}, game.entitySpriteLayer),
    ]
    self.counterCooldownTimer = bclib.Timer.Create(game.counterCooldownAmount, @onTimeout, false, false)
    self.nextWaveTimer = bclib.Timer.Create(0, @onNextWave, false, false)
end function

states[eStates.PLAYING].enter = function(self)
    // game.starManager.setActive true
    self.input.x = 0
    self.input.y = 0
    self.input.a = 0
    self.input.b = 0
    self.hud.renderCockpit
    self.wasB1 = false
    self.wasB2 = false
    game.bCanCounter = true
    mouse.locked = true

    if Levels.mode == Levels.eLevelMode.CAMPAIGN then
        self.planets = Planet.Create(ceil(mathUtil.randRange(0, game.SCREEN_WIDTH)), ceil(mathUtil.randRange(0, game.SCREEN_HEIGHT)), Levels.Campaign[Levels.level].planets, -1)
    end if
    self.canProceedWave = true
    game.sounds["soundscape"].play game.musicVolume
    game.setTickerMsg "Let's go!"
end function

states[eStates.PLAYING].tick = function(self, delta)
    logger.trace "Inside state::Playing tick"
    game.starManager.tick delta
    logger.trace "- Finished starManager tick"
    
    mx = key.axis("Mouse X")
    my = key.axis("Mouse Y")
    mz = key.axis("Mouse ScrollWheel")

    self.input.x += mx
    self.input.y += (my*-1)
    self.input.a = mz > 0
    self.input.b = mz < 0

    self.input.x = mathUtil.clamp(self.input.x, -10, 10)  // Horizontal control
    self.input.y = mathUtil.clamp(self.input.y, -10, 10) // Vertical control

    // This is if we want dampeners
    if mx == 0 and abs(self.input.x) < 2 then self.input.x = mathUtil.moveTowards(self.input.x, 0, 0.001)
    if my == 0 and abs(self.input.y) < 2 then self.input.y = mathUtil.moveTowards(self.input.y, 0, 0.001)

    isB1 = mouse.button
    if isB1 and not self.wasB1 then
        doFire = true
    else
        doFire = false
    end if
    self.wasB1 = isB1

    isB2 = mouse.button(1)
    if isB2 and not self.wasB2 then
        if not game.bCanCounter then
            doCounter = false
        else
            doCounter = true
            game.bCanCounter = false
            self.counterCooldownTimer.start
        end if
    else
        doCounter = false
    end if
    self.wasB2 = isB2

    logger.trace "- Finished input gathering"

    for laz in self.lasers
        if doFire then
            if laz.canFire then
                laz.fire
                doFire = false
            end if
        end if
        laz.tick delta
    end for

    logger.trace "- Finished laser firing"

    //while game.enemies.len < 3
        //pool = [Enemy, Satellite]
        // e = pool.any.Create(ceil(mathUtil.randRange(0, game.SCREEN_WIDTH)), ceil(mathUtil.randRange(0, game.SCREEN_HEIGHT)), ceil(mathUtil.randRange(0, 359)), ceil(mathUtil.randRange(700, 900)))
        //e = Satellite.Create(ceil(mathUtil.randRange(0, game.SCREEN_WIDTH)), ceil(mathUtil.randRange(0, game.SCREEN_HEIGHT)), ceil(mathUtil.randRange(0, 359)), ceil(mathUtil.randRange(700, 900)))
    //    e = Enemy.Create(ceil(mathUtil.randRange(0, game.SCREEN_WIDTH)), ceil(mathUtil.randRange(0, game.SCREEN_HEIGHT)), ceil(mathUtil.randRange(0, 359)), ceil(mathUtil.randRange(700, 900)))
    //    game.enemies.push e
    //    game.entitySpriteLayer.sprites.push e
    //end while

    if self.canProceedWave and Levels.wave < Levels.Campaign[Levels.level].waves.len then
        w = Levels.Campaign[Levels.level].waves[Levels.wave]
        self.canProceedWave = false
        self.nextWaveTimer.restart w.predelay
    end if
        // spawn wave
        for i in range(0, w.amount)
            dir = Level.resolveDirection(w.direction)
            distance = Level.resolveDistance(w.distance)
            e = w.type.Create(direction.x, direction.y, ceil(mathUtil.randRange(-1, 360)), distance)
            e.front = dir.front
            game.enemies.push e
            game.entitySpriteLayer.sprites.push e
        end for
    end if

    self.planets.setDrift self.input.x, self.input.y
    self.planets.tick delta

    bEnemyLock = false
    if game.enemies.len > 0 then
        for i in range(game.enemies.len-1)
            if game.enemies[i].needsDelete then
                //explosion = Explosion.Create(game.enemies[i].x, game.enemies[i].y, game.enemies[i].distance)
                //game.explosions.push explosion
                //game.entitySpriteLayer.sprites.push explosion
                game.entitySpriteLayer.sprites.removeVal game.enemies[i] // Order is important here and the next line
                game.enemies.remove i
            else
                game.enemies[i].setDrift(self.input.x, self.input.y)
                game.enemies[i].tick delta
                if game.enemies[i].isLocking then bEnemyLock = true
            end if
        end for
    end if
    self.hud.showLock bEnemyLock
    if bEnemyLock then
        if not game.sounds["locking"].isPlaying then game.sounds["locking"].play game.sfxVolume
    else
        game.sounds["locking"].stop
    end if

    logger.trace "- Finished Enemy tick"

    //for i in range(game.explosions-1)
        //game.explosions.tick delta
    //end for

    logger.trace "- Finished explosions ticking"

    bMissileLock = false
    if game.missiles.len > 0 then
        for i in range(game.missiles.len-1)
            if game.missiles[i].needsDelete then
                //explosion = Explosion.Create(game.enemies[i].x, game.enemies[i].y, game.enemies[i].distance)
                //game.explosions.push explosion
                //game.entitySpriteLayer.sprites.push explosion
                game.entitySpriteLayer.sprites.removeVal game.missiles[i] // Order is important here and the next line
                game.missiles.remove i
            else
                if doCounter then
                    game.missiles[i].getCountered
                end if
                game.missiles[i].setDrift(self.input.x, self.input.y)
                game.missiles[i].tick delta
                if game.missiles[i].isLocking then bMissileLock = true
            end if
        end for
    end if
    self.hud.showLaunch bMissileLock
    if bMissileLock then
        if not game.sounds["trackedMissile"].isPlaying then game.sounds["trackedMissile"].play game.sfxVolume
    else
        game.sounds["trackedMissile"].stop
    end if

    logger.trace "- Finished missile ticking"

    game.starManager.setDrift self.input.x, self.input.y
    logger.trace "- Finished drifting stars"

    self.hud.setDrift self.input.x, self.input.y
    self.hud.tick delta, self.counterCooldownTimer.timeLeft / game.counterCooldownAmount

    self.counterCooldownTimer.tick delta

    self.debugLabel.print "input: " + self.input
    if key.pressed("q") then
        self.machine.getContext.engine.quit
    end if
    if key.pressed("m") then mouse.locked = true
    if key.pressed("n") then mouse.locked = false

    if game.playerHealth <= 0 then self.machine.raiseEvent(eEvents.ENDGAME)
end function

states[eStates.PLAYING].exit = function(self)
    // mouse.visible = true
    // game.sounds["soundscape"].play game.musicVolume
    self.debugLabel.clear
    game.sounds["locking"].stop
    game.sounds["trackedMissile"].stop
end function

states[eStates.GAMEOVER].init = function(self)
    machine = self.machine
    onTimeout = function(timer)
        machine.raiseEvent(eEvents.DONE)
    end function

    self.label = bclib.TextLabel.Create({"row":game.SCREEN_TEXT_HEIGHT/2, "column":game.SCREEN_TEXT_WIDTH/2, "justification":bclib.TextLabel.eJustificationType.CENTER})
    self.timer = bclib.Timer.Create(5, @onTimeout, false, false)
end function

states[eStates.GAMEOVER].enter = function(self)
    // game.starManager.setActive true
    game.enemies = []
    game.missiles = []
    game.entitySpriteLayer.clear

    game.HUDSpriteLayer.clear
    game.HUDLayer.clear

    text.clear

    game.sounds["soundscape"].stop
    game.sounds["action_music"].stop

    self.label.print "GAME OVER"

    self.timer.start
end function

states[eStates.GAMEOVER].tick = function(self, delta)
    self.timer.tick delta
end function

states[eStates.GAMEOVER].exit = function(self)
    self.label.clear
end function

states[eStates.CLEARLEVELSCREEN].enter = function(self)

end function

states[eStates.CLEARLEVELSCREEN].tick = function(self, delta)

end function

states[eStates.CLEARLEVELSCREEN].exit = function(self)

end function

// State machine itself

logger = bclib.Logger.Create(file.open("log/hello.log", "w"))

machine = bclib.Machine.Create(states, eStates.LOADING)
machine.deinit = function(self, engine)
    key.clear
    mouse.locked = false
end function

machine.init = function(self, engine)
    self.setContext {"engine":engine}
    self.start
end function

// Engine that runs everything

engine = bclib.Engine.Create([machine, logger])
engine.add game.sounds.values
engine.add game.tickerTimer
engine.run