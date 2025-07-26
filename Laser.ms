Laser = {}
LaserSprite = new Sprite
LaserSprite.image = file.loadImage("/sys/pics/shapes/Hexagon.png")

LaserSprite.Create = function(color, speed, pointOrigin, pointTarget)
    instance = new self
    instance.tint = color
    instance.speed = speed
    instance.pointOrigin = pointOrigin
    instance.currentPoint = pointOrigin // maybe don't need
    instance.pointTarget = pointTarget
    instance.originalCorners = instance.corners
    instance.x = pointOrigin.x
    instance.y = pointOrigin.y
    instance.keepMoving = true
    instance.moveTrail = false
    instance.needsDelete = false

    //corners = instance.corners
    //corners[3][0] = corners[2][0]
    //corners[3][1] = corners[2][1]
    //instance.setCorners corners
    return instance
end function

LaserSprite.tick = function(self, delta)
    if self.keepMoving then
        corners = self.corners

        if self.moveTrail then
            p = {"x" :corners[0][0], "y":corners[0][1]}
            q = {"x" :corners[1][0], "y":corners[1][1]}
        else
            p = {"x" :corners[2][0], "y":corners[2][1]}
            q = {"x" :corners[3][0], "y":corners[3][1]}
        end if

        didMoveP = mathUtil.moveTowardsXY(p, self.pointTarget, self.speed)
        didMoveQ = mathUtil.moveTowardsXY(q, self.pointTarget, self.speed)
        didMove = didMoveP or didMoveQ

        if self.moveTrail then 
            corners[0][0] = p.x     // Lower left
            corners[0][1] = p.y

            corners[1][0] = q.x     // Lower Right
            corners[1][1] = q.y
        else
            corners[2][0] = p.x     // Top Right
            corners[2][1] = p.y

            corners[3][0] = q.x     // Top Left
            corners[3][1] = q.y
        end if
        
        if not didMove then
            if self.moveTrail then
                self.keepMoving = false
                self.needsDelete = true
            else
                self.moveTrail = true
            end if
        end if
        self.setCorners corners
    end if
end function

Laser.Create = function(color, speed, pointOrigin, pointTarget, display)
    instance = new self
    instance.display = display
    instance.color = color
    instance.speed = speed
    instance.pointOrigin = pointOrigin
    instance.currentPoint = pointOrigin // maybe don't need
    instance.pointTarget = pointTarget
    instance.cooldownTimer = bclib.Timer.Create(0.25, instance, false, false)
    instance.bCanFire = true
    instance.sprList = []

    instance.hitZone = new Bounds
    instance.hitZone.x = pointTarget.x-5
    instance.hitZone.y = pointTarget.y-5
    instance.hitZone.width = 5
    instance.hitZone.height = 5
    return instance
end function

Laser.onTimeout = function(self, timer)
    self.bCanFire = true
end function

Laser.canFire = function(self)
    return self.bCanFire
end function

Laser.checkHitBox = function(self)
    for e in game.enemies
        if self.hitZone.overlaps(e.worldBounds) then
            e.takeDamage(1)
            break
        end if
    end for
end function

Laser.fire = function(self)
    // Make a new LaserSprite
    if self.bCanFire then
        spr = LaserSprite.Create(self.color, self.speed, self.pointOrigin, self.pointTarget)
        self.sprList.push spr
        self.display.sprites.push spr
        self.bCanFire = false
        self.cooldownTimer.start
    end if
end function

Laser.tick = function(self, delta)
    // for all lasers, tick
    // if need delete, check hitbox and delete
    if self.sprList.len > 0 then
        for i in range(self.sprList.len-1)
            if self.sprList[i].needsDelete then
                self.checkHitBox
                self.display.sprites.removeVal self.sprList[i] // Order is important here and the next line
                self.sprList.remove i
            else
                self.sprList[i].tick delta
            end if
        end for
    end if

    self.cooldownTimer.tick delta
end function

return Laser