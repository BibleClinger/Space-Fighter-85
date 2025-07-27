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
    game.initVariables
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
    self.debugLabel = bclib.TextLabel.Create({"row":game.SCREEN_TEXT_HEIGHT-1, "column":game.SCREEN_TEXT_WIDTH/2, "justification":bclib.TextLabel.eJustificationType.CENTER})
    self.input = {}
    self.hud = HUD.Create(game.HUDLayer)
    self.lasers = [
        Laser.Create(color.blue, 150, {"x":0, "y":0}, {"x":game.SCREEN_WIDTH/2, "y":floor(game.SCREEN_HEIGHT/2 + game.SCREEN_HEIGHT/4)}, game.entitySpriteLayer),
        Laser.Create(color.red, 150, {"x":game.SCREEN_WIDTH, "y":0}, {"x":game.SCREEN_WIDTH/2, "y":floor(game.SCREEN_HEIGHT/2 + game.SCREEN_HEIGHT/4)}, game.entitySpriteLayer),
    ]
end function

states[eStates.PLAYING].enter = function(self)
    // game.starManager.setActive true
    self.input.x = 0
    self.input.y = 0
    self.input.a = 0
    self.input.b = 0
    self.hud.renderCockpit
    self.wasB1 = false
    mouse.locked = true
    game.sounds["soundscape"].play game.musicVolume
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

    self.input.x = mathUtil.clamp(self.input.x, -15, 15)  // Horizontal control
    self.input.y = mathUtil.clamp(self.input.y, -15, 15) // Vertical control

    // This is if we want dampeners
    // if mx == 0 then self.input.x = mathUtil.moveTowards(self.input.x, 0, 0.01)
    // if my == 0 then self.input.y = mathUtil.moveTowards(self.input.y, 0, 0.01)

    isB1 = mouse.button
    if isB1 and not self.wasB1 then
        doFire = true
    else
        doFire = false
    end if
    self.wasB1 = isB1

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

    while game.enemies.len < 2
        e = Enemy.Create(ceil(mathUtil.randRange(0, game.SCREEN_WIDTH)), ceil(mathUtil.randRange(0, game.SCREEN_HEIGHT)), ceil(mathUtil.randRange(0, 359)), ceil(mathUtil.randRange(700, 900)))
        game.enemies.push e
        game.entitySpriteLayer.sprites.push e
    end while
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
            end if
        end for
    end if

    logger.trace "- Finished Enemy tick"

    //for i in range(game.explosions-1)
        //game.explosions.tick delta
    //end for

    logger.trace "- Finished explosions ticking"

    if game.missiles.len > 0 then
        for i in range(game.missiles.len-1)
            if game.missiles[i].needsDelete then
                //explosion = Explosion.Create(game.enemies[i].x, game.enemies[i].y, game.enemies[i].distance)
                //game.explosions.push explosion
                //game.entitySpriteLayer.sprites.push explosion
                game.entitySpriteLayer.sprites.removeVal game.missiles[i] // Order is important here and the next line
                game.missiles.remove i
            else
                game.missiles[i].setDrift(self.input.x, self.input.y)
                game.missiles[i].tick delta
            end if
        end for
    end if

    logger.trace "- Finished missile ticking"

    game.starManager.setDrift self.input.x, self.input.y
    logger.trace "- Finished drifting stars"

    self.hud.setDrift self.input.x, self.input.y
    self.hud.tick delta

    self.debugLabel.print "input: " + self.input
    if key.pressed("q") then
        self.machine.getContext.engine.quit
    end if
    if key.pressed("m") then mouse.locked = true
    if key.pressed("n") then mouse.locked = false
end function

states[eStates.PLAYING].exit = function(self)
    // mouse.visible = true
    // game.sounds["soundscape"].play game.musicVolume
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
engine.add(game.sounds.values)
engine.run