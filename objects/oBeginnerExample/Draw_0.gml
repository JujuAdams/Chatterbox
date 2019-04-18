//Iterate over all text and draw it

var _x = 10;
var _y = 10;

var _text_count = chatterbox_get_string_count(chatterbox, CHATTERBOX_BODY);
for(var _i = 0; _i < _text_count; _i++)
{
    draw_text(_x, _y, chatterbox_get_string(chatterbox, CHATTERBOX_BODY, _i));
    _y += 20;
}

_y += 20;

var _option_count = chatterbox_get_string_count(chatterbox, CHATTERBOX_OPTION);
for(var _i = 0; _i < _option_count; _i++)
{
    draw_text(_x, _y, string(_i+1) + ") " + chatterbox_get_string(chatterbox, CHATTERBOX_OPTION, _i));
    _y += 20;
}