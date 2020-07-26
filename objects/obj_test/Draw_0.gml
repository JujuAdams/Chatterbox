//Iterate over all text and draw it
var _x = 10;
var _y = 10;

//All the spoken text
var _i = 0;
repeat(array_length(box.content))
{
    draw_text(_x, _y, box.content[_i]);
    _y += 20;
    ++_i;
}

//Bit of spacing...
_y += 20;

//All the options
var _i = 0;
repeat(array_length(box.option))
{
    draw_text(_x, _y, string(_i+1) + ") " + string(box.option[_i]));
    _y += 20;
    ++_i;
}