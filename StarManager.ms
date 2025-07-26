StarManager = {}

StarManager.Create = function(amount, edge, starDisplay)
    instance = new self
    instance.amount = amount
    instance.edge = edge
    instance.starDisplay = starDisplay
    instance.stars = []
    instance.active = true
    instance.dx = 0
    instance.dy = 0
    return instance
end function

StarManager.setActive = function(self, active)
    self.active = active
    if not self.active then self.removeAllStars
end function

StarManager.setDrift = function(self, dx, dy)
    self.dx = dx
    self.dy = dy
end function

StarManager.tick = function(self, delta)
    if self.active then
    //    if key.pressed("up") then dy = -5
    //    if key.pressed("down") then dy = 5
    //    if key.pressed("left") then dx = 5
    //    if key.pressed("right") then dx = -5
    //    if key.pressed("q") then self.engine.quit

        while self.stars.len < 10
            star = Star.Create(self.edge)
            self.stars.push star
            self.starDisplay.sprites.push star
        end while
        needDelete = []
        for s in self.stars
            if not s.delete then
                s.tick delta, self.dx, self.dy
            else
                needDelete.push s
            end if
        end for

        for s in needDelete
            self.removeStar s
        end for
    end if
end function

StarManager.removeAllStars = function(self, star)
    self.stars = []
    self.starDisplay.sprites = []
end function

StarManager.removeStar = function(self, star)
    self.stars.removeVal(star)
    self.starDisplay.sprites.removeVal(star)
end function

return StarManager