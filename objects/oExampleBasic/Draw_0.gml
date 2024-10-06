// Feather disable all

draw_set_font(fntDefault);

//Iterate over all text and draw it
var _x = 10;
var _y = 10;
var _height = string_height("M");

if (ChatterboxIsStopped(box))
{
    //If we're stopped then show that
    draw_text(_x, _y, "(Chatterbox stopped)");
}
else
{
    //All the spoken text
    var _i = 0;
    repeat(ChatterboxGetContentCount(box))
    {
        var _string = ChatterboxGetContent(box, _i);
        draw_text(_x, _y, _string);
        _y += _height;
        ++_i;
    }
    
    //Bit of spacing...
    _y += 30;

    if (ChatterboxIsWaiting(box))
    {
        //If we're in a "waiting" state then prompt the user for basic input
        draw_text(_x, _y, "(Press Space)");
        _y += _height;
    }
    else
    {
        //All the options
        var _i = 0;
        repeat(ChatterboxGetOptionCount(box))
        {
            var _string = ChatterboxGetOption(box, _i);
            draw_text(_x, _y, string(_i+1) + ") " + _string);
            _y += _height;
            ++_i;
        }
    }
    
    //Bit more spacing...
    _y += 30;
    
    draw_text(_x, _y, "Node = " + string(ChatterboxGetCurrent(box)));
    _y += _height;
    draw_text(_x, _y, "Previous = " + string(ChatterboxGetPrevious(box)));
}