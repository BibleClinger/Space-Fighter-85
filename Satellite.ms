Satellite = new Enemy
Satellite.src = file.loadImage("images/satelite-sprite_sheet.png")
Satellite.HUDimage = file.loadImage("/sys/pics/shapes/CircleThin.png")
Satellite.imageBank = {}
Satellite.spriteWidth = 512
Satellite.spriteHeight = 512
Satellite.maxSpeed = 5

d = 0
for j in range(3, 0)
    for i in range(0, 3)
        Satellite.imageBank[Satellite.degrees[d]] = Satellite.src.getImage(i*Satellite.spriteWidth, j*Satellite.spriteHeight, Satellite.spriteWidth, Satellite.spriteHeight)
        d += 1
    end for
end for

Satellite.Create = function(x, y, heading, distance)
    e = super.Create(x, y, heading, distance)
    e.speed = 0.25
    e.scaleShip
    return e
end function

Satellite.doBehavior = function(self, delta)
    self.heading += 1
    if game.isInZone(self) then
        if self.front then self.distance -= self.speed else self.distance += self.speed
    end if
end function

Satellite.tick = function(self, delta)
    self.doBehavior delta
    self.heading = self.heading + 360
    self.heading %= 360

    self.confirmImage
    self.scaleShip

    if self.distance > 1000 then
        self.distance = 1000
    else if self.distance < 10 then
        self.distance = 10
    end if

    self.wrapProtection
    if self.front then self.tint = color.white else self.tint = color.red
end function

Satellite.takeDamage = function(self, damage)
    super.takeDamage damage
    if self.needsDelete then
        game.enemiesKilled -= 1 // We don't want to count as an enemy
        game.objectsKilled += 1 // We'd rather count as an object
        game.doObjectBonus
    end if
end function

return Satellite