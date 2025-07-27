Explosion = spriteControllers.Animated
Explosion.src = file.loadImage("images/explosion-spritesheet.png")
Explosion.frames = []

for j in range(2, 0)
    for i in range(0, 2)
        Explosion.frames.push Explosion.src.getImage(i)
    end for
end for

Explosion.Create = function(x, y, distance)
    instance = new self
    instance.x = x
    instance.y = y
    instance.distance = distance // set scale
    instance.explosionAnim = spriteControllers.newAnimation(self.frames, 10)
    instance.explosionAnim.loop = false
    instance.play(instance.explosionAnim)
    return instance
end function

Explosion.tick = function(self, delta)
    self.update delta
    if self.explosionAnim.curFrame == -1 then
        game.entitySpriteLayer.sprites.removeVal self
        game.explosions.removeVal self
    end if
end function

return Explosion