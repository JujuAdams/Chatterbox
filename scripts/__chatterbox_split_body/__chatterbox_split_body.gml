/// @param bodyString

function __chatterbox_split_body(_body)
{
	var _body_substring_list = ds_list_create();
    
	var _body_byte_length = string_byte_length(_body);
	var _body_buffer = buffer_create(_body_byte_length+1, buffer_fixed, 1);
	buffer_poke(_body_buffer, 0, buffer_string, _body);
    
	var _line          = 0;
	var _first_on_line = true;
	var _indent        = undefined;
	var _newline       = false;
	var _cache         = "";
	var _cache_type    = "text";
	var _prev_value    = 0;
	var _value         = 0;
	var _next_value    = buffer_read(_body_buffer, buffer_u8);
    
	repeat(_body_byte_length)
	{
	    _prev_value = _value;
	    _value      = _next_value;
	    _next_value = buffer_read(_body_buffer, buffer_u8);
        
	    var _write_cache = true;
	    var _pop_cache   = false;
        
	    if ((_value == ord("\n")) || (_value == ord("\r")))
	    {
	        _newline     = true;
	        _pop_cache   = true;
	        _write_cache = false;
	    }
	    else if (_value == ord(CHATTERBOX_OPTION_OPEN_DELIMITER))
	    {
	        if (_next_value == ord(CHATTERBOX_OPTION_OPEN_DELIMITER))
	        {
	            _write_cache = false;
	            _pop_cache   = true;
	        }
	        else if (_prev_value == ord(CHATTERBOX_OPTION_OPEN_DELIMITER))
	        {
	            _write_cache = false;
	            _cache_type = "option";
	        }
	    }
	    else if (_value == ord(CHATTERBOX_OPTION_CLOSE_DELIMITER))
	    {
	        if (_next_value == ord(CHATTERBOX_OPTION_CLOSE_DELIMITER))
	        {
	            _write_cache = false;
	            _pop_cache   = true;
	        }
	        else if (_prev_value == ord(CHATTERBOX_OPTION_CLOSE_DELIMITER))
	        {
	            _write_cache = false;
	        }
	    }
	    else if (_value == ord(CHATTERBOX_ACTION_OPEN_DELIMITER))
	    {
	        if (_next_value == ord(CHATTERBOX_ACTION_OPEN_DELIMITER))
	        {
	            _write_cache = false;
	            _pop_cache   = true;
	        }
	        else if (_prev_value == ord(CHATTERBOX_ACTION_OPEN_DELIMITER))
	        {
	            _write_cache = false;
	            _cache_type = "action";
	        }
	    }
	    else if (_value == ord(CHATTERBOX_ACTION_CLOSE_DELIMITER))
	    {
	        if (_next_value == ord(CHATTERBOX_ACTION_CLOSE_DELIMITER))
	        {
	            _write_cache = false;
	            _pop_cache   = true;
	        }
	        else if (_prev_value == ord(CHATTERBOX_ACTION_CLOSE_DELIMITER))
	        {
	            _write_cache = false;
	        }
	    }
        
	    if (_write_cache) _cache += chr(_value);
        
	    if (_pop_cache)
	    {
	        if (_first_on_line)
	        {
	            _cache = __chatterbox_remove_whitespace(_cache, true);
	            _indent = global.__chatterbox_indent_size;
	        }
            
	        if (_cache != "") ds_list_add(_body_substring_list, [_cache, _cache_type, _line, _indent]);
	        _cache = "";
	        _cache_type = "text";
            
	        if (_newline)
	        {
	            _newline = false;
	            ++_line;
	            _first_on_line = true;
	            _indent = undefined;
	        }
	        else
	        {
	            _first_on_line = false;
	        }
	    }
	}
    
	buffer_delete(_body_buffer);
    
    ds_list_add(_body_substring_list, ["stop", "action", _line, 0]);
    return _body_substring_list;
}