globals.game = {}

game.initVariables = function
    // Inner callback
    onTimeout = function(timer)
        if game.tickerMsg.len > 0 then
            game.ticker.print game.tickerMsg
            game.tickerMsg = game.tickerMsg[1:] // trickery. This would crash in other languages
        else
            timer.stop
        end if
    end function


    // SCREEN variables
    game.SCREEN_WIDTH = 960
    game.SCREEN_HEIGHT = 640
    game.SCREEN_TEXT_WIDTH = 68
    game.SCREEN_TEXT_HEIGHT = 26
    game.MAX_DISTANCE = 1000
    game.MIN_DISTANCE = 10

    // Sounds

    game.sfxVolume = 0.5
    game.musicVolume = 0.3

    game.sounds = {}
    game.sounds["title_music"] = bclib.Audio.Clip.load("sounds/space3.ogg")
    game.sounds["soundscape"] = bclib.Audio.Clip.load("sounds/Space Soundscape - 1.ogg")
    game.sounds["action_music"] = bclib.Audio.Clip.load("sounds/actionsoundtrack.ogg")
    game.sounds["action_music"].loop = true
    game.sounds["pew"] = bclib.Audio.Clip.load("sounds/sound fx - beam 1.ogg")
    game.sounds["pew_explode"] = bclib.Audio.Clip.load("sounds/sound fx - beam 2.ogg")
    game.sounds["heartbeat"] = bclib.Audio.Clip.load("sounds/sound fx - heartbeat.ogg")
    game.sounds["locking"] = bclib.Audio.Clip.load("sounds/sound fx - rwr.ogg")
    game.sounds["locking"].loop = true
    game.sounds["trackedMissile"] = bclib.Audio.Clip.load("sounds/sound fx - rwr locked.ogg")
    game.sounds["trackedMissile"].loop = true
    //engine.add(game.sounds.values) // Chicken + egg issue

    // Layer variables
    game.backgroundLayer = new SolidColorDisplay    // background
    game.backgroundLayer.install 7
    game.starSpriteLayer = new SpriteDisplay        // Star background
    game.starSpriteLayer.install 6
    game.entitySpriteLayer = new SpriteDisplay
    game.entitySpriteLayer.install 5                // Entity layer
    game.HUDLayer = new PixelDisplay
    game.HUDLayer.install 4                         // HUD layer
    //                                              // Text layer
    game.HUDSpriteLayer = new SpriteDisplay
    game.HUDSpriteLayer.install 2                   // Sprite HUD layer

    // Labels

    bclib.Functions.importToDestination("spriteControllers", globals)
    bclib.Functions.importToDestination("Star", globals)
    bclib.Functions.importToDestination("StarManager", globals)
    bclib.Functions.importToDestination("Enemy", globals)
    bclib.Functions.importToDestination("HUD", globals)
    bclib.Functions.importToDestination("Laser", globals)
    bclib.Functions.importToDestination("Explosion", globals)
    bclib.Functions.importToDestination("Missile", globals)
    bclib.Functions.importToDestination("Satellite", globals)
    bclib.Functions.importToDestination("Levels", globals)
    bclib.Functions.importToDestination("Planet", globals)

    // Player variables
    game.playerMaxHealth = 15

    game.cheers = file.readLines("db/cheers.txt")
    game.ticker = bclib.TextLabel.Create({"row":9, "column":27+13/2, "justification":bclib.TextLabel.eJustificationType.CENTER, "maxLen":13})
    game.tickerTimer = bclib.Timer.Create(0.15, @onTimeout, true, true)
end function

game.clearLayers = function
    game.entitySpriteLayer.clear
    game.starSpriteLayer.clear
    game.HUDLayer.clear color.clear
    game.HUDSpriteLayer.clear
    game.backgroundLayer.color = color.black
end function

game.isInZone = function(object)
    return object.x > 267 and object.x < 693 and object.y > 345 and object.y < 544
end function

game.playerTakeDamage = function(source, damage)
    onTimeout = function(timer)
        con = timer.getContext
        if con % 2 then
            game.backgroundLayer.color = "#DD4D00"
        else 
            game.backgroundLayer.color = color.black
        end if
        con -= 1
        timer.setContext con

        if con < 0 then
            timer.stop
            engine.remove(timer)
        end if
    end function

    game.playerHealth -= damage
    if not game.sounds["heartbeat"].isPlaying then
        game.sounds["heartbeat"].play game.sfxVolume
    end if
    timer = bclib.Timer.Create(0.15, @onTimeout, true, true, 1)
    engine.add(timer)

    game.damageTaken += 1
end function

game.reset = function
    // Lists
    game.enemies = []
    game.explosions = []
    game.missiles = []

    game.enemiesKilled = 0
    game.objectsKilled = 0
    game.missilesCountered = 0
    game.missilesTaken = 0
    game.missilesDodged = 0
    game.damageTaken = 0

    // Player variables
    game.playerHealth = 5
    game.counterCooldownAmount = 3
    game.bCanCounter = true

    // Ticker variables
    game.tickerMsg = ""
    game.tickerLength = 13

    Levels.mode = Levels.eLevelMode.CAMPAIGN
    Levels.level = 0
end function

game.doObjectBonus = function
    game.playerHealth += 5
    if game.playerMaxHealth then game.playerHealth = game.playerMaxHealth
end function

game.setTickerMsg = function(msg)
    game.tickerMsg = " "*game.tickerLength + msg + " "*game.tickerLength
    game.tickerTimer.start
end function

game.clearTicker = function
    game.tickerMsg = ""
    game.ticker.clear
end function

game.initVariables
game.reset