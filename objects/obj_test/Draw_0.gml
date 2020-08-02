//Iterate over all text and draw it
var _x = 10;
var _y = 10;

if (chatterbox_is_stopped(box))
{
    //If we're stopped then show that
    draw_text(_x, _y, "(Chatterbox stopped)");
}
else
{
    //All the spoken text
    var _i = 0;
    repeat(chatterbox_get_content_count(box))
    {
        draw_text(_x, _y, chatterbox_get_content(box, _i));
        _y += 20;
        ++_i;
    }
    
    //Bit of spacing...
    _y += 20;

    if (chatterbox_is_waiting(box))
    {
        //If we're in a "waiting" state then prompt the user for basic input
        draw_text(_x, _y, "(Press Space)");
    }
    else
    {
        //All the options
        var _i = 0;
        repeat(chatterbox_get_option_count(box))
        {
            draw_text(_x, _y, string(_i+1) + ") " + chatterbox_get_option(box, _i));
            _y += 20;
            ++_i;
        }
    }
}