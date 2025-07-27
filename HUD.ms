HUD = {}
HUD.cockpit = file.loadImage("images/ui_overlay.png")
HUD.arrowX = file.loadImage("/sys/pics/arrows/arrow1.png")
HUD.arrowY = file.loadImage("/sys/pics/arrows/arrow1.png")
HUD.enemyAbove = file.loadImage("/sys/pics/shapes/TriangleThin.png")
HUD.enemyBelow = file.loadImage("/sys/pics/shapes/TriangleThick.png")
HUD.missileImage = file.loadImage("/sys/pics/1bitTiles.png").getImage(17*16, 0, 16, 16)
HUD.lightOn = file.loadImage("images/ui_parts/LED_on.png")

HUD.Create = function(display)
    instance = new self
    instance.display = display
    
    instance.compassX = new Sprite
    instance.compassX.image = self.arrowX
    instance.compassX.x = game.SCREEN_WIDTH/2
    instance.compassX.y = 110
    instance.compassX.scale = [0.5, 0.1]
    instance.compassX.tint = "#DD4D00"

    instance.compassY = new Sprite
    instance.compassY.image = self.arrowY
    instance.compassY.x = game.SCREEN_WIDTH/2
    instance.compassY.y = 110
    instance.compassY.scale = [0.1, 0.5]
    instance.compassY.tint = "#DD4D00"

    instance.lockSprite = new Sprite
    instance.lockSprite.image = instance.lightOn
    instance.lockSprite.x = 325
    instance.lockSprite.y = 33
    instance.lockSprite.scale = 0.3046875 // very specific :P
    instance.lockSprite.tint = color.clear

    instance.launchSprite = new Sprite
    instance.launchSprite.image = instance.lightOn
    instance.launchSprite.x = 325
    instance.launchSprite.y = 83
    instance.launchSprite.scale = 0.3046875 // very specific :P
    instance.launchSprite.tint = color.clear

    instance.counter = bclib.TextLabel.Create({"row":9, "column":3, "prefix":"Counter: ", "color":"#DD4D00"}) 
    instance.health = bclib.TextLabel.Create({"row":7, "column":3, "prefix":"Health: ", "color":"#DD4D00"})
    instance.enemies = bclib.TextLabel.Create({"row":5, "column":3, "prefix":"Enemies: ", "color":"#DD4D00"})
    instance.missiles = bclib.TextLabel.Create({"row":3, "column":3, "prefix":"Missiles: ", "color":"#DD4D00"})

    instance.lockTimer = bclib.Timer.Create(0.1, instance, false, true, instance.lockSprite)
    instance.launchTimer = bclib.Timer.Create(0.1, instance, false, true, instance.launchSprite)
    return instance
end function

HUD.onTimeout = function(self, timer)
    s = timer.getContext
    if s.tint == color.clear then s.tint = "#DD4D00" else s.tint = color.clear
end function

HUD.renderCockpit = function(self)
    self.display.drawImage self.cockpit
    game.HUDSpriteLayer.sprites.push self.compassX
    game.HUDSpriteLayer.sprites.push self.compassY
    game.HUDSpriteLayer.sprites.push self.lockSprite
    game.HUDSpriteLayer.sprites.push self.launchSprite
end function

HUD.setDrift = function(self, dx, dy)
    // Scale both X and Y arrows
    self.compassX.scale = [mathUtil.lerp(0, 0.5, abs(dx/15)), 0.1]
    self.compassY.scale = [mathUtil.lerp(0, 0.5, abs(dy/15)), 0.1]

    // Move X arrow along the X axis
    self.compassX.x = game.SCREEN_WIDTH/2
    if dx < 0 then
        self.compassX.rotation = 180
        self.compassX.x -= floor(self.compassX.image.width*self.compassX.scale[0]*0.5)
    else
        self.compassX.x += floor(self.compassX.image.width*self.compassX.scale[0]*0.5)
        self.compassX.rotation = 0
    end if

    // Move Y arrow along the Y axis
    self.compassY.y = 110
    if dy < 0 then 
        self.compassY.rotation = 90
        self.compassY.y += floor(self.compassY.image.height*self.compassY.scale[0]*0.5)
    else
        self.compassY.rotation = 270
        self.compassY.y -= floor(self.compassY.image.height*self.compassY.scale[0]*0.5)
    end if
end function

HUD.showLaunch = function(self, turnOn)
    self.launch = turnOn
    if turnOn then
        self.launchTimer.start
    else
        self.launchTimer.stop
        self.launchSprite.tint = color.clear
    end if
end function

HUD.showLock = function(self, turnOn)
    self.lock = turnOn
    if turnOn then
        self.lockTimer.start
    else
        self.lockTimer.stop
        self.lockSprite.tint = color.clear
    end if
end function

HUD.tick = function(self, delta, cooldown)
    self.lockTimer.tick delta
    self.launchTimer.tick delta

    // Draw enemies on radar
    game.HUDSpriteLayer.sprites = game.HUDSpriteLayer.sprites[0:4]
    for e in game.enemies
        s = new Sprite
        s.image = e.HUDimage
        s.scale = [0.1, 0.3]
        if e.y >= game.SCREEN_HEIGHT/2 and e.front then s.tint = color.red else s.tint = color.blue
        
        if e.front then
            s.rotation = -e.heading
            s.x = mathUtil.lerp(720, 930, (e.x - e.leftLimit) / (e.rightLimit - e.leftLimit))
            s.y = mathUtil.lerp(160, 270, (e.distance - 10) / (1000 - 10))
        else
            s.rotation = (e.heading + 180) % 360
            s.x = mathUtil.lerp(930, 720, (e.x - e.leftLimit) / (e.rightLimit - e.leftLimit))
            s.y = mathUtil.lerp(145, 60, (e.distance - 10) / (1000 - 10))
        end if
        game.HUDSpriteLayer.sprites.push s
    end for

    for m in game.missiles
        s = new Sprite
        s.image = HUD.missileImage
        if m.y >= game.SCREEN_HEIGHT/2 and m.front then s.tint = color.pink else s.tint = color.teal
        if m.front then
            s.x = mathUtil.lerp(720, 930, (m.x - m.leftLimit) / (m.rightLimit - m.leftLimit))
            s.y = mathUtil.lerp(160, 270, (m.distance - 10) / (1000 - 10))
        else
            s.x = mathUtil.lerp(930, 720, (m.x - m.leftLimit) / (m.rightLimit - m.leftLimit))
            s.y = mathUtil.lerp(145, 60, (m.distance - 10) / (1000 - 10))
        end if
        game.HUDSpriteLayer.sprites.push s
    end for

    if game.bCanCounter then
        self.counter.print "RDY!"
    else
        self.counter.print mathUtil.numToStr(cooldown, 2)
    end if

    self.health.print game.playerHealth
    self.enemies.print game.enemies.len
    self.missiles.print game.missiles.len
end function

return HUD