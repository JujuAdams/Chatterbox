//Iterate over all text and draw it
var _x = 10;
var _y = 10;

var _i = 0;
repeat(array_length(box.strings))
{
    draw_text(_x, _y, box.strings[_i]);
    _y += 20;
    ++_i;
}

_y += 20;

var _i = 0;
repeat(array_length(box.options))
{
    draw_text(_x, _y, string(_i+1) + ") " + string(box.options[_i]));
    _y += 20;
    ++_i;
}