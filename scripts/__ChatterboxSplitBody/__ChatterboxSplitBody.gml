/// @param sourceBuffer
/// @param bufferStart
/// @param bufferEnd
/// @param applyStringReplacement

function __ChatterboxSplitBody(_source_buffer, _source_buffer_start, _source_buffer_end, _apply_string_replacement)
{
    if (__CHATTERBOX_DEBUG_SPLITTER) __ChatterboxTrace("Splitting body of node \"", title, "\" in file \"", filename, "\", metadata = ", metadata);
    
    var _buffer = _source_buffer;
    var _buffer_offset = 0;
    
    //Poke in a null byte at the end of the read area so we know where to stop
    buffer_seek(_source_buffer, buffer_seek_start, _source_buffer_start);
    var _final_byte = buffer_peek(_source_buffer, _source_buffer_end+1, buffer_u8);
    buffer_poke(_source_buffer, _source_buffer_end+1, buffer_u8, 0x00);
    
    //If we want to perform any string replacement then we'll need to extract the raw string from the source buffer, transform it, and write it to its own buffer
    if (_apply_string_replacement && (ds_list_size(global.__chatterboxFindReplaceOldString) > 0))
    {
        _buffer_offset = _source_buffer_start;
        
        var _work_string = buffer_read(_source_buffer, buffer_string);
        buffer_seek(_source_buffer, buffer_seek_start, _source_buffer_start);
        
        //Perform find-replace
        var _i = 0;
        repeat(ds_list_size(global.__chatterboxFindReplaceOldString))
        {
            _work_string = string_replace_all(_work_string,
                                                global.__chatterboxFindReplaceOldString[| _i],
                                                global.__chatterboxFindReplaceNewString[| _i]);
            ++_i;
        }
        
        var _buffer = buffer_create(string_byte_length(_work_string)+1, buffer_fixed, 1);
        buffer_write(_buffer, buffer_string, _work_string);
        buffer_seek(_buffer, buffer_seek_start, 0);
    }
    
    var _substring_array = [];
    
    var _string_start = buffer_tell(_buffer);
    var _string_end   = _string_start; 
    
    var _type   = "text";
    var _line   = 0;
    var _indent = 0;
    
    var _find_indent = true;
    var _in_comment  = false;
    var _in_metadata = false;
    var _in_action   = false;
    
    var _func_read_string = function(_substring_array, _buffer, _string_start, _string_end, _type, _line, _indent, _buffer_offset)
    {
        if (_string_start >= _string_end)
        {
            if (_type == "text")
            {
                if (__CHATTERBOX_DEBUG_SPLITTER) __ChatterboxTrace("Empty text string");
                return;
            }
            
            _text = "";
        }
        else
        {
            var _old_tell = buffer_tell(_buffer);
            var _old_byte = buffer_peek(_buffer, _string_end+1, buffer_u8);
            buffer_poke(_buffer, _string_end+1, buffer_u8, 0x00);
            buffer_seek(_buffer, buffer_seek_start, _string_start);
            var _text = buffer_read(_buffer, buffer_string);
            buffer_poke(_buffer, _string_end+1, buffer_u8, _old_byte);
            buffer_seek(_buffer, buffer_seek_start, _old_tell);
        }
        
        if (__CHATTERBOX_DEBUG_SPLITTER)
        {
            __ChatterboxTrace("Read \"", _text, "\", writing as type=", _type, ", line=", _line, ", indent=", _indent);
        }
        
        array_push(_substring_array, [_text, _type, _line, _indent]);
        
        //array_push(_substring_array, {
        //    buffer_start: _buffer_offset + _string_start,
        //    buffer_end:   _buffer_offset + _string_end,
        //    
        //    text:   _text,
        //    type:   _type,
        //    line:   _line,
        //    indent: _indent,
        //});
    }
    
    if (__CHATTERBOX_DEBUG_SPLITTER) __ChatterboxTrace("Line = ", _line);
    
    while(true) //Read until we hit the terminating null
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        
        if ((_byte == 0x00) || (_byte == 0x0A) || (_byte == 0x0D)) //  null, \n, or \r
        {
            if (_in_action) __ChatterboxError("Unfinished action found in node \"", title, "\" in file \"", filename, "\"");
            
            if (__CHATTERBOX_DEBUG_SPLITTER) __ChatterboxTrace("Found newline");
            
            if (_in_comment)
            {
                //Do nothing!
                if (__CHATTERBOX_DEBUG_SPLITTER) __ChatterboxTrace("In comment, not writing substring");
            }
            else
            {
                _func_read_string(_substring_array,
                                  _buffer, _string_start, _string_end,
                                  _type, _line, _indent,
                                  _buffer_offset);
            }
            
            if (_byte == 0x00) break;
            
            //If this is \r\n then skip over the \n to avoid double-counting newlines
            if ((_byte == 0x0D) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == 0x0A))
            {
                buffer_seek(_buffer, buffer_seek_relative, 1);
            }
            
            _find_indent = true;
            _in_comment  = false;
            _in_metadata = false;
            
            _type   = "text";
            _indent = 0;
            _line++;
            
            _string_start = buffer_tell(_buffer);
            _string_end   = _string_start-1;
            
            if (__CHATTERBOX_DEBUG_SPLITTER) __ChatterboxTrace("Line = ", _line);
        }
        else if (_in_comment)
        {
            //Do nothing!
        }
        else if (_find_indent)
        {
            if (_byte == 0x20)
            {
                ++_indent;
                ++_string_start;
                ++_string_end;
            }
            else if (_byte == 0x09)
            {
                _indent += CHATTERBOX_INDENT_TAB_SIZE;
                ++_string_start;
                ++_string_end;
            }
            else
            {
                _find_indent = false;
                if (__CHATTERBOX_DEBUG_SPLITTER) __ChatterboxTrace("Found start of content, ident=", _indent);
                
                //Re-parse this byte
                buffer_seek(_buffer, buffer_seek_relative, -1);
            }
        }
        else
        {
            if (_byte == ord("#") && (buffer_peek(_buffer, max(0, buffer_tell(_buffer)-2), buffer_u8) != ord("\\"))) // # but without leading \
            {
                if (__CHATTERBOX_DEBUG_SPLITTER) __ChatterboxTrace("Found start of metdata");
                
                _func_read_string(_substring_array,
                                  _buffer, _string_start, _string_end,
                                  _type, _line, _indent,
                                  _buffer_offset);
                
                _type = "metadata";
                _in_metadata = true;
                
                _string_start = buffer_tell(_buffer);
                _string_end   = _string_start-1;
            }
            else if ((_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("/"))) //   //
            {
                if (__CHATTERBOX_DEBUG_SPLITTER) __ChatterboxTrace("Found start of comment");
                
                _func_read_string(_substring_array,
                                  _buffer, _string_start, _string_end,
                                  _type, _line, _indent,
                                  _buffer_offset);
                
                _type = "comment";
                _in_comment = true;
                
                buffer_seek(_buffer, buffer_seek_relative, 1);
            }
            else if ((_byte == ord(__CHATTERBOX_ACTION_OPEN_DELIMITER)) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord(__CHATTERBOX_ACTION_OPEN_DELIMITER)))
            {
                if (__CHATTERBOX_DEBUG_SPLITTER) __ChatterboxTrace("Found start of action");
                
                _func_read_string(_substring_array,
                                  _buffer, _string_start, _string_end,
                                  _type, _line, _indent,
                                  _buffer_offset);
                
                _type = "command";
                _in_action = true;
                
                buffer_seek(_buffer, buffer_seek_relative, 1);
                _string_start = buffer_tell(_buffer);
                _string_end   = _string_start-1;
            }
            else if (_in_action && (_byte == ord(__CHATTERBOX_ACTION_CLOSE_DELIMITER)) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord(__CHATTERBOX_ACTION_CLOSE_DELIMITER)))
            {
                if (__CHATTERBOX_DEBUG_SPLITTER) __ChatterboxTrace("Found end of action");
                
                _func_read_string(_substring_array,
                                  _buffer, _string_start, _string_end,
                                  _type, _line, _indent,
                                  _line, _indent,
                                  _buffer_offset);
                
                _type = "text";
                _in_action = false;
                
                buffer_seek(_buffer, buffer_seek_relative, 1);
                _string_start = buffer_tell(_buffer);
                _string_end   = _string_start-1;
            }
            else if (_byte > 0x20)
            {
                _string_end = buffer_tell(_buffer)-1;
            }
        }
    }
    
    if (_buffer != _source_buffer) buffer_delete(_buffer);
    
    //Restore the final byte of the source buffer
    buffer_poke(_source_buffer, _source_buffer_end+1, buffer_u8, _final_byte);
    
    return _substring_array;
}



function __ChatterboxSplitBody__OLD(_source_buffer, _source_buffer_start, _source_buffer_end, _apply_string_replacement)
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
    
    buffer_delete(_body_buffer);
    
    return _in_substring_array;
}