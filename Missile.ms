Missile = new Sprite
Missile.image = file.loadImage("images/missile.png")
Missile.speed = 15

Missile.degrees = range(180, 0, -22.5) + range(360-22.5, 180+22.5, -22.5)
Missile.imageBank = {}
Missile.spriteWidth = 512
Missile.spriteHeight = 512
d = 0
for j in range(3, 0)
    for i in range(0, 3)
        //Enemy.imageBank[Enemy.degrees[d]] = Enemy.src.getImage(i*Enemy.spriteWidth, j*Enemy.spriteHeight, Enemy.spriteWidth, Enemy.spriteHeight)
        d += 1
    end for
end for

//Enemy.eBehavior = bclib.Enum.Create("FLYAWAY FLYCLOSE FLYLATERAL LOCK FIREMISSILE FIREDUMB")
//Enemy.eGoal = bclib.Enum.Create("AVOID PATROL ATTACK DERP")

Missile.Create = function(x, y, distance, front, locked)
    instance = new self
    instance.x = x
    instance.y = y
    instance.distance = distance
    instance.locked = locked
    instance.front = front
    instance.target = {
        "x":game.SCREEN_WIDTH/2,
        "y":game.SCREEN_HEIGHT/2,
    }
    instance.currenAim = {
        "x":game.SCREEN_WIDTH/2,
        "y":game.SCREEN_HEIGHT/2,
    }

    instance.localBounds = new Bounds
    instance.localBounds.x = 0
    instance.localBounds.x = 0
    instance.localBounds.width = instance.image.width
    instance.localBounds.width = instance.image.height

    instance.health = 1
    instance.needsDelete = false

    instance.scaleObject

    instance.label = bclib.TextLabel.Create({"row":20, "column":0})
    instance.label.print "front is: " + front + " Lock: " + instance.locked

    game.missiles.push instance
    game.entitySpriteLayer.sprites.push instance
    return instance
end function

Missile.setDrift = function(self, dx, dy)
    if not self.locked then
        self.x -= dx
        self.y += dy
    else
        // Drift into cockpit view fast when locked
        mathUtil.moveTowardsXY(self, self.target, self.speed)
    end if
end function

Missile.getCountered = function(self)
    if self.locked then
        self.locked = false
    end if
end function 

Missile.explode = function(self)
    if self.locked then
        game.sounds["trackedMissile"].stop
        game.playerTakeDamage(self, 2)
    else
        //if self.x > game.SCREEN_WIDTH/2-100 and self.x < game.SCREEN_WIDTH/2+100 and self.y > game.SCREEN_HEIGHT/2-100 and self.y < game.SCREEN_HEIGHT/2+100 and self.distance < 15 then
        if self.x > 267 and self.x < 693 and self.y > 345 and self.y < 544 and self.distance < 15 then
            game.playerTakeDamage(self, 1)
        end if
    end if
    self.needsDelete = true
end function

Missile.tick = function(self, delta)
    if self.locked and not game.sounds["trackedMissile"].isPlaying then game.sounds["trackedMissile"].play
    self.distance -= self.speed
    self.scaleObject
    if self.distance <= 10 or self.distance > 1000 then
        self.explode
    end if
    self.wrapProtection
    if self.front then self.tint = color.white else self.tint = color.red
    self.label.print "Front: " + self.front + " Distance: " + self.distance
end function

Missile.wrapProtection = function(self)
    //if self.x < self.leftLimit then self.x = game.SCREEN_WIDTH + self.spriteWidth*self.scale
    if self.x < self.leftLimit then
        self.x = self.rightLimit - 1
        self.front = not self.front
    else if self.x > self.rightLimit then
    //if self.x > self.rightLimit + self.spriteWidth*self.scale then self.x = -self.spriteWidth*self.scale
        self.x = self.leftLimit + 1
        self.front = not self.front
    end if
    if self.y < (-self.image.width*self.scale) then
        self.y = game.SCREEN_HEIGHT + self.image.height*self.scale
        self.front = not self.front
    else if self.y > game.SCREEN_HEIGHT + self.image.height*self.scale then
        self.y = -self.image.height*self.scale
        self.front = not self.front
    end if
end function

Missile.scaleObject = function(self)
    self.scale = mathUtil.lerp(0.50, 0.01, (self.distance-10) / (1000-10))
end function

Missile.leftLimit = function(self)
    return (-self.image.width*self.scale)
end function

Missile.rightLimit = function(self)
    return game.SCREEN_WIDTH + self.image.width*self.scale
end function

return Missile