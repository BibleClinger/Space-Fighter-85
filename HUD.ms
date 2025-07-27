HUD = {}
HUD.cockpit = file.loadImage("images/ui_overlay.png")
HUD.arrowX = file.loadImage("/sys/pics/arrows/arrow1.png")
HUD.arrowY = file.loadImage("/sys/pics/arrows/arrow1.png")
HUD.enemyAbove = file.loadImage("/sys/pics/shapes/TriangleThin.png")
HUD.enemyBelow = file.loadImage("/sys/pics/shapes/TriangleThick.png")

HUD.Create = function(display)
    instance = new self
    instance.display = display
    
    instance.compassX = new Sprite
    instance.compassX.image = self.arrowX
    instance.compassX.x = game.SCREEN_WIDTH/2
    instance.compassX.y = 100
    instance.compassX.scale = [0.5, 0.1]

    instance.compassY = new Sprite
    instance.compassY.image = self.arrowY
    instance.compassY.x = game.SCREEN_WIDTH/2
    instance.compassY.y = 100
    instance.compassY.scale = [0.1, 0.5]
    return instance
end function

HUD.renderCockpit = function(self)
    self.display.drawImage self.cockpit
    game.HUDSpriteLayer.sprites.push self.compassX
    game.HUDSpriteLayer.sprites.push self.compassY
end function

HUD.setDrift = function(self, dx, dy)
    if dx < 0 then self.compassX.rotation = 180 else self.compassX.rotation = 0
    if dy < 0 then self.compassY.rotation = 90 else self.compassY.rotation = 270

    self.compassX.scale = [mathUtil.lerp(0, 0.5, abs(dx/15)), 0.1]
    self.compassX.x = game.SCREEN_WIDTH/2 + game.SCREEN_WIDTH/2*self.compassX.scale
    self.compassY.scale = [mathUtil.lerp(0, 0.5, abs(dy/15)), 0.1]
    self.compassX.y = 100 + 100*self.compassY.scale
end function

HUD.tick = function(self, delta)
    // Draw enemies on radar
    game.HUDSpriteLayer.sprites = game.HUDSpriteLayer.sprites[0:2]
    for e in game.enemies
        s = new Sprite
        s.image = HUD.enemyAbove
        s.scale = [0.1, 0.5]
        if e.y >= game.SCREEN_HEIGHT/2 then s.tint = color.red else s.tint = color.blue
        //if e.heading > 90 and e.heading < 270 then s.rotation = 180 else s.rotation = 0

        if e.front then
            s.rotation = e.heading
            s.x = mathUtil.lerp(722, 940, (e.x - e.leftLimit) / (e.rightLimit - e.leftLimit))
            s.y = mathUtil.lerp(160, 270, (e.distance - 10) / (1000 - 10))
        else
            s.rotation = 180 - e.heading
            if s.rotation < 0 then s.rotation += 360
            s.x = mathUtil.lerp(722, 940, ((game.SCREEN_WIDTH - e.x) - e.leftLimit) / (e.rightLimit - e.leftLimit))
            s.y = mathUtil.lerp(150, 60, (e.distance - 10) / (1000 - 10))
        end if
        game.HUDSpriteLayer.sprites.push s
    end for
end function

return HUD