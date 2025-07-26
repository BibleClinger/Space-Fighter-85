Enemy = new Sprite
Enemy.degrees = range(180, 0, -22.5) + range(360-22.5, 180+22.5, -22.5)
Enemy.imageBank = {}
Enemy.spriteWidth = 512
Enemy.spriteHeight = 512
Enemy.src = file.loadImage("images/enemy-spritesheet.png")
d = 0
for j in range(3, 0)
    for i in range(0, 3)
        Enemy.imageBank[Enemy.degrees[d]] = Enemy.src.getImage(i*Enemy.spriteWidth, j*Enemy.spriteHeight, Enemy.spriteWidth, Enemy.spriteHeight)
        d += 1
    end for
end for

Enemy.Create = function(x, y, heading, distance)
    instance = new self
    instance.x = x
    instance.y = y
    instance.heading = heading
    instance.distance = distance
    spriteWidth = 512
    spriteHeight = 512

    instance.doClockWise = false
    instance.getCloser = true
    instance.label = bclib.TextLabel.Create({"row":0, "column":0})
    instance.label2 = bclib.TextLabel.Create({"row":4, "column":0})

    instance.localBounds = new Bounds
    instance.localBounds.x = 0
    instance.localBounds.x = 0
    instance.localBounds.width = spriteWidth
    instance.localBounds.width = spriteHeight

    instance.health = 5
    instance.needsDelete = false

    return instance
end function

Enemy.confirmImage = function(self)
    for d in self.degrees
        gap = d - self.heading
        absgap = abs(gap)
        if absgap == 180 then
            realgap = absgap
        else if absgap < 180 then
            realgap = gap
        else if d > self.heading then
            realgap = absgap - 360
        else
            realgap = 360 - absgap
        end if

        self.label.print "heading: " + self.heading + " " + "degree: " + d + " " + " realgap: " + realgap

        if abs(realgap) <= 22.5/2 then
            self.image = self.imageBank[d] // hack
            //if abs((self.heading+360) - (d+360)) <= 22.5 then self.image = self.imageBank[d] // hack
            break
        end if
    end for
end function

Enemy.scaleShip = function(self)
    self.scale = mathUtil.lerp(1, 0.01, (self.distance-10) / (1000-10))
    self.label2.print "distance: " + self.distance + " scale: " + self.scale
end function

Enemy.doBehavior = function(self, delta)
    // We derp
    // We can set heading, and we can adjust speed
    // We can fire on the player
    // We can blow up
    // if self.getCloser then

end function

Enemy.derpy = function(self)
    if self.doClockWise then
        self.heading += 1
    else
        self.heading -= 1
    end if
    while self.heading < 0
        self.heading += 360
    end while
    if self.distance >= 10 then
        self.distance -= 10
    else if self.distance <= 1000 then
        self.distance += 10
    end if
end function

Enemy.tick = function(self, delta)
    self.doBehavior delta
    self.heading %= 360

    if self.distance > 1000 then
        self.distance = 1000
    else if self.distance < 10 then
        self.distance = 10
    end if

    self.confirmImage
    self.scaleShip
end function

Enemy.takeDamage = function(self, damage)
    self.health -= damage
    if self.health <= 0 then self.needsDelete = true
end function

return Enemy