// Feather disable all

function __ChatterboxStripLeadingWhitespace(_string)
{
    var _i = 0;
    repeat(string_length(_string))
    {
        if (ord(string_char_at(_string, _i+1)) > 32) break;
        ++_i;
    }
    
    return string_delete(_string, 1, _i);
}
