globals.game = {}

game.initVariables = function
    // SCREEN variables
    game.SCREEN_WIDTH = 960
    game.SCREEN_HEIGHT = 640
    game.SCREEN_TEXT_WIDTH = 68
    game.SCREEN_TEXT_HEIGHT = 26

    // Layer variables
    game.entitySpriteLayer = display(4)
    game.starSpriteLayer = new SpriteDisplay
    game.starSpriteLayer.install 6
    display(6).mode = game.starSpriteLayer.mode
    game.HUDLayer = display(5)
    game.backgroundLayer = display(7)

    // Labels

    // Star Manager

    bclib.Functions.importToDestination("Star", globals)
    bclib.Functions.importToDestination("StarManager", globals)

end function

game.clearLayers = function
    game.entitySpriteLayer.sprites = []
    game.starSpriteLayer.sprites = []
    game.HUDLayer.clear color.clear
    game.backgroundLayer = color.black
end function
