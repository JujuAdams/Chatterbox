var _x = 10;
var _y = 10;

if (ChatterboxIsStopped(box))
{
    draw_text(_x, _y, "(Chatterbox stopped)");
}
else
{
    var _i = 0;
    repeat(ChatterboxGetContentCount(box))
    {
        draw_text(_x, _y, ChatterboxGetContent(box, _i));
        _y += 20;
        ++_i;
    }
    
    _y += 20;
    
    if (ChatterboxIsWaiting(box))
    {
        draw_text(_x, _y, "(Press Space)");
    }
    else
    {
        var _i = 0;
        repeat(ChatterboxGetOptionCount(box))
        {
            draw_text(_x, _y, string(_i+1) + ") " + ChatterboxGetOption(box, _i));
            _y += 20;
            ++_i;
        }
    }
}