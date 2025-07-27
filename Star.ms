Star = new Sprite
Star.image = file.loadImage("/sys/pics/shapes/Circle.png")
Star.maxScale = 0.1
Star.minScale = 0.01
Star.speed = 4
Star.startColor = color.clear
Star.endColor = color.white

Star.Create = function(edge)
    s = new self
    // s.edge = edge
    s.x = mathUtil.randRange(edge, game.SCREEN_WIDTH - edge)
    s.y = mathUtil.randRange(edge, game.SCREEN_HEIGHT - edge)
    s.rotation = atan(s.y - game.SCREEN_HEIGHT/2, s.x - game.SCREEN_WIDTH/2) * 180/pi // Look away from center of screen
    if s.x == game.SCREEN_WIDTH / 2 or s.y == game.SCREEN_WIDTH then return null // temp "fix"
    s.scale = mathUtil.randRange(s.minScale, s.maxScale)
    s.delete = false
    s.speed = mathUtil.lerp(0.001, 2, (s.scale - s.minScale) / (s.maxScale - s.minScale)) // This may be wrong.
    //print s.speed
    s.tint = s.startColor
    s.lerptick = 0.1
    return s
end function

Star.setScale = function(self)
    // Wrong, but we want to scale down as we leave the screen
    // Star.scale = lerp(self.minScale, self.maxScale, min(self)) // we can scale based on distance of x to mid or y to mid, whichever we want
    // Star.scale = lerp(self.minScale, self.maxScale, distance(self, [SCREEN_WIDTH/2, SCREEN_HEIGHT/2]))
end function

Star.move = function(self, delta, awayPoint, dx, dy)
    self.rotation = atan(self.y - awayPoint.y, self.x - awayPoint.x) * 180/pi // Look away from the awayPoint
    ang = self.rotation * pi/180
    self.speed += 0.02
    if dx == 0 then dx = 1
    if dy == 0 then dy = 1
	self.x = self.x + cos(ang) * (self.speed + abs(dx))
	self.y = self.y + sin(ang) * (self.speed + abs(dy))
end function

Star.tick = function(self, delta, dx, dy)
    // If upper left quadrant, then go upper left
    // etc.
    // Need formula for distance.
    if not self.tint == self.endColor then
        self.tint = color.lerp(self.startColor, self.endColor, self.lerptick)
        self.lerptick += 0.1
    end if

    p = {
        "x" : mathUtil.lerp(0, game.SCREEN_WIDTH, (dx+10) / (10+10)),
        "y" : mathUtil.lerp(game.SCREEN_HEIGHT, 0, (dy+10) / (10+10)),
    }

    self.move delta, p, dx, dy

    // Scale down star as it gets farther away
    self.setScale
    // Speed up star as it gets closer to the edge of the screen

    if self.x < 0 or self.x > game.SCREEN_WIDTH or self.y < 0 or self.y > game.SCREEN_HEIGHT then
        self.delete = true
    end if
end function

return Star