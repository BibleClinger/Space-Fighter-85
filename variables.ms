globals.game = {}

game.initVariables = function
    // SCREEN variables
    game.SCREEN_WIDTH = 960
    game.SCREEN_HEIGHT = 640
    game.SCREEN_TEXT_WIDTH = 68
    game.SCREEN_TEXT_HEIGHT = 26
    game.MAX_DISTANCE = 1000
    game.MIN_DISTANCE = 10

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

    game.enemies = []
    game.explosions = []
end function

game.clearLayers = function
    game.entitySpriteLayer.sprites = []
    game.starSpriteLayer.sprites = []
    game.HUDLayer.clear color.clear
    game.backgroundLayer = color.black
end function
