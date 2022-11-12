/// @param sourceBuffer
/// @param bufferStart
/// @param bufferEnd
/// @param applyStringReplacement

function __ChatterboxSplitBody(_source_buffer, _source_buffer_start, _source_buffer_end, _apply_string_replacement)
{
	buffer_seek(_source_buffer, buffer_seek_start, _source_buffer_start);
	var _final_byte = buffer_peek(_source_buffer, _source_buffer_end+1, buffer_u8);
	buffer_poke(_source_buffer, _source_buffer_end+1, buffer_u8, 0x00);
	var _work_string = buffer_read(_source_buffer, buffer_string);
	buffer_poke(_source_buffer, _source_buffer_end+1, buffer_u8, _final_byte);
	
	if (__CHATTERBOX_DEBUG_COMPILER) __ChatterboxTrace("Splitting body of node \"", title, "\" (", __ChatterboxStringLimit(_work_string, 100), ")    ", metadata);
	
	if (_apply_string_replacement)
	{
	    //Prepare body string for parsing
	    _work_string = string_replace_all(_work_string, "\n\r", "\n");
	    _work_string = string_replace_all(_work_string, "\r\n", "\n");
	    _work_string = string_replace_all(_work_string, "\r"  , "\n");
		
	    //Perform find-replace
	    var _i = 0;
	    repeat(ds_list_size(global.__chatterboxFindReplaceOldString))
	    {
	        _work_string = string_replace_all(_work_string,
	                                          global.__chatterboxFindReplaceOldString[| _i],
	                                          global.__chatterboxFindReplaceNewString[| _i]);
	        ++_i;
	    }
	}
	
    //Add a trailing newline to make sure we parse correctly
    _work_string += "\n";
	
    var _in_substring_array = [];
    
    var _body_byte_length = string_byte_length(_work_string);
    var _body_buffer = buffer_create(_body_byte_length+1, buffer_fixed, 1);
    buffer_write(_body_buffer, buffer_string, _work_string);
    buffer_seek(_body_buffer, buffer_seek_start, 0);
    
    var _line          = 0;
    var _first_on_line = true;
    var _indent        = undefined;
    var _newline       = false;
    var _cache         = "";
    var _cache_type    = "text";
    var _prev_value    = 0;
    var _value         = 0;
    var _next_value    = __ChatterboxReadUTF8Char(_body_buffer);
    var _in_comment    = false;
    var _in_metadata   = false;
    var _in_action     = false;
    
    repeat(_body_byte_length)
    {
        if (_next_value == 0) break;
        
        _prev_value = _value;
        _value      = _next_value;
        _next_value = __ChatterboxReadUTF8Char(_body_buffer);
        
        var _write_cache = true;
        var _pop_cache   = false;
        
        if ((_value == ord("\n")) || (_value == ord("\r")))
        {
            _newline     = true;
            _pop_cache   = true;
            _write_cache = false;
            _in_comment  = false;
            _in_metadata = false;
        }
        else if (_in_comment)
        {
            _write_cache = false;
        }
        else if (_in_metadata)
        {
            if ((_value == ord("/")) && (_next_value == ord("/")))
            {
                _in_comment  = true;
                _pop_cache   = true;
                _write_cache = false;
            }
            else if (_value == ord("#"))
            {
                _pop_cache   = true;
                _write_cache = false;
            }
        }
        else
        {
            if ((_prev_value != ord("\\")) && (_value == ord("#")) && !_in_action)
            {
                _in_metadata = true;
                _pop_cache   = true;
                _write_cache = false;
            }
            else if ((_value == ord("/")) && (_next_value == ord("/")) && !_in_action)
            {
                _in_comment  = true;
                _pop_cache   = true;
                _write_cache = false;
            }
            else if (_value == ord(__CHATTERBOX_ACTION_OPEN_DELIMITER))
            {
                if (_next_value == ord(__CHATTERBOX_ACTION_OPEN_DELIMITER))
                {
                    _write_cache = false;
                    _pop_cache   = true;
                }
                else if (_prev_value == ord(__CHATTERBOX_ACTION_OPEN_DELIMITER))
                {
                    _write_cache = false;
                    _cache_type  = "command";
                    _in_action   = true;
                }
            }
            else if (_value == ord(__CHATTERBOX_ACTION_CLOSE_DELIMITER))
            {
                if (_next_value == ord(__CHATTERBOX_ACTION_CLOSE_DELIMITER))
                {
                    _write_cache = false;
                    _pop_cache   = true;
                }
                else if (_prev_value == ord(__CHATTERBOX_ACTION_CLOSE_DELIMITER))
                {
                    _write_cache = false;
                    _in_action   = false;
                }
            }
        }
        
        if (_write_cache) _cache += chr(_value);
        
        if (_pop_cache)
        {
            if (_first_on_line)
            {
                _cache = __ChatterboxCompilerRemoveWhitespace(_cache, true);
                _indent = global.__chatterboxIndentSize;
            }
            else if (_in_metadata)
            {
                _cache = __ChatterboxCompilerRemoveWhitespace(_cache, true);
                _indent = 0;
            }
            
            _cache = __ChatterboxCompilerRemoveWhitespace(_cache, false);
            
            if (_cache != "") array_push(_in_substring_array, [_cache, _cache_type, _line, _indent]);
            _cache = "";
            _cache_type = _in_metadata? "metadata" : "text";
            
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
	
    array_push(_in_substring_array, [CHATTERBOX_END_OF_NODE_HOPBACK? "hopback" : "stop", "command", _line, 0]);
    
    buffer_delete(_body_buffer);
    
    return _in_substring_array;
}