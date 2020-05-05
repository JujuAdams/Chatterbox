//Iterate over all text and draw it

var _x = 10;
var _y = 10;

var _text_count = chatterbox_body_count(chatterbox);
for(var _i = 0; _i < _text_count; _i++)
{
    draw_text(_x, _y, chatterbox_body_get(chatterbox, _i));
    _y += 20;
}

_y += 20;

var _option_count = chatterbox_option_count(chatterbox);
for(var _i = 0; _i < _option_count; _i++)
{
    draw_text(_x, _y, string(_i+1) + ") " + chatterbox_option_get(chatterbox, _i));
    _y += 20;
}