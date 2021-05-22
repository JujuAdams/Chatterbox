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
        var _string = ChatterboxGetContent(box, _i);
        draw_text(_x, _y, _string);
        _y += string_height(_string);
        ++_i;
    }
    
    //Bit of spacing...
    _y += 30;

    if (ChatterboxIsWaiting(box))
    {
        //If we're in a "waiting" state then prompt the user for basic input
        var _string = "(Press Space)";
        draw_text(_x, _y, _string);
        _y += string_height(_string);
    }
    else
    {
        //All the options
        var _i = 0;
        repeat(ChatterboxGetOptionCount(box))
        {
            var _string = ChatterboxGetOption(box, _i);
            draw_text(_x, _y, string(_i+1) + ") " + _string);
            _y += string_height(_string);
            ++_i;
        }
    }
    
    //More spacing...
    _y += 30;
    
    //Draw all node metadata
    var _metadata = ChatterboxGetCurrentMetadata(box);
    var _names = variable_struct_get_names(_metadata);
    var _i = 0;
    repeat(array_length(_names))
    {
        var _name = _names[_i];
        var _value = _metadata[$ _name];
        var _string = "metadata \"" + string(_name) + "\" = \"" + _value + "\"";
        draw_text(_x, _y, _string);
        _y += string_height(_string);
        ++_i;
    }
}