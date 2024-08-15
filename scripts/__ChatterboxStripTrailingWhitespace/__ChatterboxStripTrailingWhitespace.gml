// Feather disable all

function __ChatterboxStripTrailingWhitespace(_string)
{
    var _i = string_length(_string);
    repeat(_i)
    {
        if (ord(string_char_at(_string, _i)) > 32) break;
        --_i;
    }
    
    return string_copy(_string, 1, _i);
}