import "bclib"

text.clear

engine = bclib.Engine.Create
label = bclib.TextLabel.Create({"column":68/2, "row":26/2, "justification":bclib.TextLabel.eJustificationType.CENTER, "maxLen":10})

pack = function(msg, space)
    return (" "*space) + msg + (" "*space)
end function

timedOut = function(timer)
    con = timer.getContext

    label.print con.text

    if con.text.len > 0 then
        con.text = con.text[1:]
    else
        con.engine.quit
    end if
end function

timer = bclib.Timer.Create(0.1, @timedOut, true, true, {"engine":engine, "text":pack("Hello world!", 10), "oldText":""})
engine.add timer 
engine.run