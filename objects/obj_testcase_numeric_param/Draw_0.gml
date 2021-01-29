var _x = 10;
var _y = 10;

if (chatterbox_is_stopped(box))
{
    draw_text(_x, _y, "(Chatterbox stopped)");
}
else
{
    var _i = 0;
    repeat(chatterbox_get_content_count(box))
    {
        draw_text(_x, _y, chatterbox_get_content(box, _i));
        _y += 20;
        ++_i;
    }
    
    _y += 20;
    
    if (chatterbox_is_waiting(box))
    {
        draw_text(_x, _y, "(Press Space)");
    }
    else
    {
        var _i = 0;
        repeat(chatterbox_get_option_count(box))
        {
            draw_text(_x, _y, string(_i+1) + ") " + chatterbox_get_option(box, _i));
            _y += 20;
            ++_i;
        }
    }
}