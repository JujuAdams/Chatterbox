//Iterate over all text and draw it
var _x = 10;
var _y = 10;

var _i = 0;
repeat(chatterbox_body_count(chatterbox))
{
    draw_text(_x, _y, chatterbox_body_get(chatterbox, _i));
    _y += 20;
    ++_i;
}

_y += 20;

var _i = 0;
repeat(chatterbox_option_count(chatterbox))
{
    draw_text(_x, _y, string(_i+1) + ") " + chatterbox_option_get(chatterbox, _i));
    _y += 20;
    ++_i;
}