/// @param string
/// @param leading

var _string  = argument0;
var _leading = argument1;

global.__chatterbox_indent_size = 0;

if (_leading)
{
    var _i = 1;
    repeat(string_length(_string))
    {
        var _ord = ord(string_char_at(_string, _i));
        if (_ord  > 32) break;
        if (_ord == 32) global.__chatterbox_indent_size++;
        if (_ord ==  9) global.__chatterbox_indent_size += CHATTERBOX_INDENT_UNIT_SIZE;
        _i++;
    }
    
    return string_delete(_string, 1, _i-1);
}
else
{
    var _i = string_length(_string);
    repeat(string_length(_string))
    {
        var _ord = ord(string_char_at(_string, _i));
        if (_ord  > 32) break;
        if (_ord == 32) global.__chatterbox_indent_size++;
        if (_ord ==  9) global.__chatterbox_indent_size += CHATTERBOX_INDENT_UNIT_SIZE;
        _i--;
    }
    
    return string_copy(_string, 1, _i);
}