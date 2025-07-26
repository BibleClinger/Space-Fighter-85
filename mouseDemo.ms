while not key.pressed("escape")
	text.row = 10
	print "mouse.button:    " + mouse.button
	for b in range(1,6)
		print "mouse.button(" + b + "): " + mouse.button(b)
	end for
    print "mouse scroll: " + key.axis("Mouse ScrollWheel", true)
    print "mouse x: " + key.axis("Mouse X", false)
    print "mouse y: " + key.axis("Mouse Y", false)
    mouse.locked = true
    yield
end while
key.clear  // (clear escape key from key buffer)
mouse.locked = false