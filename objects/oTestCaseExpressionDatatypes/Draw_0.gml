draw_set_font(fntDefault);

//Iterate over all text and draw it
var _x = 10;
var _y = 10;

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
        draw_text(_x, _y, ChatterboxGetContent(box, _i));
        _y += 20;
        ++_i;
    }
    
    //Bit of spacing...
    _y += 20;

    if (ChatterboxIsWaiting(box))
    {
        //If we're in a "waiting" state then prompt the user for basic input
        draw_text(_x, _y, "(Press Space)");
    }
    else
    {
        //All the options
        var _i = 0;
        repeat(ChatterboxGetOptionCount(box))
        {
            draw_text(_x, _y, string(_i+1) + ") " + ChatterboxGetOption(box, _i));
            _y += 20;
            ++_i;
        }
    }
}