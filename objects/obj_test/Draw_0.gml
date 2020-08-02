//Iterate over all text and draw it
var _x = 10;
var _y = 10;

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

//All the options
var _i = 0;
repeat(chatterbox_get_option_count(box))
{
    draw_text(_x, _y, string(_i+1) + ") " + chatterbox_get_option(box, _i));
    _y += 20;
    ++_i;
}