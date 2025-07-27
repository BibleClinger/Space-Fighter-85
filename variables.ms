globals.game = {}

game.initVariables = function
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

    // Lists

    game.enemies = []
    game.explosions = []
    game.missiles = []

    // Player variables

    game.playerHealth = 5
end function

game.clearLayers = function
    game.entitySpriteLayer.sprites = []
    game.starSpriteLayer.sprites = []
    game.HUDLayer.clear color.clear
    game.backgroundLayer = color.black
end function

game.playerTakeDamage = function(source, damage)
    game.playerHealth -= damage
    if not game.sounds["heartbeat"].isPlaying then game.sounds["heartbeat"].play
end function