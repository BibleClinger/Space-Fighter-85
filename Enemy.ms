Enemy = new Sprite
Enemy.degrees = range(180, 0, -22.5) + range(360-22.5, 180+22.5, -22.5)
Enemy.imageBank = {}
Enemy.spriteWidth = 512
Enemy.spriteHeight = 512
Enemy.maxSpeed = 5
Enemy.src = file.loadImage("images/enemy-spritesheet.png")
d = 0
for j in range(3, 0)
    for i in range(0, 3)
        Enemy.imageBank[Enemy.degrees[d]] = Enemy.src.getImage(i*Enemy.spriteWidth, j*Enemy.spriteHeight, Enemy.spriteWidth, Enemy.spriteHeight)
        d += 1
    end for
end for

Enemy.eBehavior = bclib.Enum.Create("FLYAWAY FLYCLOSE FLYLATERAL LOCK FIREMISSILE FIREDUMB")
Enemy.eGoal = bclib.Enum.Create("AVOID PATROL ATTACK DERP")

Enemy.Create = function(x, y, heading, distance)
    instance = new self
    instance.x = x
    instance.y = y
    instance.heading = heading
    instance.desiredHeading = heading
    instance.distance = distance
    instance.desiredDistance = distance
    instance.behavior = instance.eBehavior.FLYCLOSE
    instance.goal = instance.eGoal.PATROL
    instance.speed = 0
    instance.desiredSpeed = 0

    instance.doClockWise = false
    instance.getCloser = true
    instance.label = bclib.TextLabel.Create({"row":0, "column":0})
    instance.label2 = bclib.TextLabel.Create({"row":24, "column":0})

    instance.localBounds = new Bounds
    instance.localBounds.x = 0
    instance.localBounds.x = 0
    instance.localBounds.width = instance.spriteWidth
    instance.localBounds.width = instance.spriteHeight

    instance.health = 5
    instance.needsDelete = false

    instance.front = true

    instance.scaleShip

    instance.bCanFire = true
    instance.successfulLockTime = 3
    instance.reloadCooldown = 15
    instance.cooldownTimer = bclib.Timer.Create(instance.reloadCooldown, instance, false, false, "FIRE")
    instance.lockTimer = bclib.Timer.Create(instance.successfulLockTime, instance, false, false, "LOCK")
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

        //self.label.print "heading: " + self.heading + " " + "degree: " + d + " " + " realgap: " + realgap

        if abs(realgap) <= 22.5/2 then
            self.image = self.imageBank[d] // hack
            //if abs((self.heading+360) - (d+360)) <= 22.5 then self.image = self.imageBank[d] // hack
            break
        end if
    end for
end function

Enemy.scaleShip = function(self)
    self.scale = mathUtil.lerp(1, 0.03, (self.distance-10) / (1000-10))
    //self.label2.print "x: " + self.x + " y: " + self.y + " distance: " + self.distance + " scale: " + self.scale
end function

Enemy.chooseBehavior = function(self)
    //if self.goal == self.eGoal.PATROL then
        //desiredHeading = 90
        //if rand(90) % 2 then desiredHeading = 270
//    end if
end function

Enemy.onTimeout = function(self, timer)
    c = timer.getContext
    if c == "LOCK" then
        self.bCanFire = false
        Missile.Create(self.x, self.y, self.distance, self.front, false)
        self.cooldownTimer.start
        self.behavior = self.eBehavior.FLYAWAY
    else if c == "FIRE" then
        self.bCanFire = true
    end if
end function

Enemy.startLock = function(self)
    self.lockTimer.start
    self.bLock = true
end function

Enemy.doBehavior = function(self, delta)
    if self.behavior == self.eBehavior.FLYCLOSE then
        if self.heading != 180 then self.desiredHeading = 180
        if self.speed != 3 then self.desiredSpeed = 3
        if not self.front then
            if self.distance < 500 then
                self.behavior = self.eBehavior.LOCK
                self.startLock
            end if
        else if self.distance < 600 and self.heading < 190 and self.heading > 170 and self.bCanFire then
            self.bCanFire = false
            Missile.Create(self.x, self.y, self.distance, self.front, false)
            self.cooldownTimer.start
            self.behavior = self.eBehavior.FLYAWAY
        else if self.distance < 450 then
            if floor(rnd + 10) % 2 then
                if floor(rnd + 10) % 2 then self.desiredHeading = 90 else self.desiredHeading = 270
                self.behavior = self.eBehavior.FLYLATERAL
            else
                self.behavior = self.eBehavior.FLYAWAY        
            end if
        end if
    else if self.behavior == self.eBehavior.FLYAWAY then
        if self.heading != 0 then self.desiredHeading = 0
        if self.speed != 4 then self.desiredSpeed = 4
        if self.distance > 750 then self.behavior = self.eBehavior.FLYCLOSE
    else if self.behavior == self.eBehavior.FLYLATERAL then
        if self.x < 0 or self.x > game.SCREEN_WIDTH then
            self.behavior = self.eBehavior.FLYAWAY
        end if
    else if self.behavior == self.eBehavior.LOCK then
        if not game.sounds["locking"].isPlaying then game.sounds["locking"].play
        if self.front then bLock = false
        if not self.bLock then
            self.behavior.FLYAWAY
            self.lockTimer.stop
        end if
    end if
end function

Enemy.moveForward = function(self)
    // self.rotation = atan(self.y - awayPoint.y, self.x - awayPoint.x) * 180/pi // Look away from the awayPoint
    // We have self.heading
    // ang = self.heading * pi/180
    // self.x = self.x + cos(ang) * self.speed
     // self.distance = self.distance + sin(ang) * self.speed
	// self.y = self.y + sin(ang) * self.speed
    if self.heading != self.desiredHeading then
        if self.doClockWise then self.heading += 1 else self.heading -= 1
    end if

    if self.desiredSpeed > self.speed then
        self.speed += 1
    else if self.desiredSpeed < self.speed then
        self.speed -= 1
    end if

    if self.heading > 90 and self.heading < 270 then
        self.distance -= self.speed
    else if self.heading < 90 or self.heading > 270 then
        self.distance += self.speed
    end if

    if self.heading > 0 and self.heading < 180 then
        self.x += floor(self.speed * 1.5)
    else if self.heading < 360 and self.heading > 180 then
        self.x -= floor(self.speed * 1.5)
    end if

    self.label.print "heading: " + self.heading + " speed: " + self.speed
end function

Enemy.setDrift = function(self, dx, dy)
    self.x -= dx
    self.y += dy
end function

Enemy.tick = function(self, delta)
    self.doBehavior delta
    self.heading = self.heading + 360
    self.heading %= 360
    
    self.moveForward

    if self.distance > 1000 then
        self.distance = 1000
    else if self.distance < 10 then
        self.distance = 10
    end if

    self.confirmImage
    self.scaleShip

    self.lockTimer.tick delta
    self.cooldownTimer.tick delta

    self.wrapProtection
    if self.front then self.tint = color.white else self.tint = color.red
end function

Enemy.leftLimit = function(self)
    return (-self.spriteWidth*self.scale)
end function

Enemy.rightLimit = function(self)
    return game.SCREEN_WIDTH + self.spriteWidth*self.scale
end function

Enemy.wrapProtection = function(self)
    //if self.x < self.leftLimit then self.x = game.SCREEN_WIDTH + self.spriteWidth*self.scale
    if self.x < self.leftLimit then
        self.x = self.rightLimit - 1
        self.front = not self.front
    else if self.x > self.rightLimit then
    //if self.x > self.rightLimit + self.spriteWidth*self.scale then self.x = -self.spriteWidth*self.scale
        self.x = self.leftLimit + 1
        self.front = not self.front
    end if

    if self.y < (-self.spriteHeight*self.scale) then
        self.y = game.SCREEN_HEIGHT + self.spriteHeight*self.scale
        self.front = not self.front
    else if self.y > game.SCREEN_HEIGHT + self.spriteHeight*self.scale then
        self.y = -self.spriteHeight*self.scale
        self.front = not self.front
    end if
end function

Enemy.takeDamage = function(self, damage)
    self.health -= damage
    if self.health <= 0 then self.needsDelete = true
end function

return Enemy