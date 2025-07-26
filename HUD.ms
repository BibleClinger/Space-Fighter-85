HUD = {}

HUD.Create = function(display)
    instance = new self
    instance.display = display
    instance.cockpit = file.loadImage("images/ui_overlay.png")
    return instance
end function

HUD.renderCockpit = function(self)
    self.display.drawImage self.cockpit
end function

HUD.tick = function(self, delta)
    // self.render delta
end function

return HUD