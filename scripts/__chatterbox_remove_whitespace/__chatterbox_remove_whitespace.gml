/// Removes whitespace from either the front or back of a string
///
/// This is an internal script, please don't modify it.
///
/// @param string
/// @param leading

function __chatterbox_remove_whitespace(_string, _leading)
{
	global.__chatterbox_indent_size = 0;
    
	if (_leading)
	{
	    var _i = 1;
	    repeat(string_length(_string))
	    {
	        var _ord = ord(string_char_at(_string, _i));
	        if (_ord  > 32) break;
	        if (_ord == 32) global.__chatterbox_indent_size++;
	        if (_ord ==  9) global.__chatterbox_indent_size += CHATTERBOX_INDENT_TAB_SIZE;
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
	        if (_ord ==  9) global.__chatterbox_indent_size += CHATTERBOX_INDENT_TAB_SIZE;
	        _i--;
	    }
        
	    return string_copy(_string, 1, _i);
	}
}