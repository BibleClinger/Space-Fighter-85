Planet = new Sprite
Planet.imageSlots = []
for name in file.children("images/moons_planets_suns")
    Planet.imageSlots.push file.loadImage("images/moons_planets_suns/" + name)
end for

Planet.Create = function(x, y, imageIndex=-1, scale=-1)
    instance = new self
    instance.front = true
    if imageIndex == -1 then imageIndex = instance.imageSlots.indexes.any
    instance.x = x
    instance.y = y
    if scale == -1 then scale = 0.5
    instance.scale = scale
    instance.image = instance.imageSlots[imageIndex]
    game.starSpriteLayer.sprites.push instance
    return instance
end function

Planet.setDrift = function(self, dx, dy)
    self.x -= dx/2
    self.y += dy/2
end function

Planet.tick = function(self, delta)
    // Put timer to watch for staring at planet for message
    self.wrapProtection
    if self.front then self.tint = color.white else self.tint = color.clear
end function

Planet.wrapProtection = function(self)
    //if self.x < self.leftLimit then self.x = game.SCREEN_WIDTH + self.spriteWidth*self.scale
    if self.x < self.leftLimit then
        self.x = self.rightLimit - 1
        self.front = not self.front
    else if self.x > self.rightLimit then
    //if self.x > self.rightLimit + self.spriteWidth*self.scale then self.x = -self.spriteWidth*self.scale
        self.x = self.leftLimit + 1
        self.front = not self.front
    end if

    if self.y < (-self.image.height*self.scale) then
        self.y = game.SCREEN_HEIGHT + self.image.height*self.scale
        self.front = not self.front
    else if self.y > game.SCREEN_HEIGHT + self.image.height*self.scale then
        self.y = -self.image.height*self.scale
        self.front = not self.front
    end if
end function

Planet.leftLimit = function(self)
    return (-self.image.width*self.scale)
end function

Planet.rightLimit = function(self)
    return game.SCREEN_WIDTH + self.image.width*self.scale
end function

return Planet