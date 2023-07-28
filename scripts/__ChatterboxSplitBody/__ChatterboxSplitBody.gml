// Feather disable all
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
    var _string_end   = _string_start-1; 
    
    var _type   = "text";
    var _line   = 0;
    var _indent = 0;
    
    var _line_is_option = false;
    var _find_indent    = true;
    var _in_comment     = false;
    var _in_metadata    = false;
    var _in_action      = false;
    
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
        
        array_push(_substring_array, new __ChatterboxClassBodySubstring(_text, _type, _line, _indent, _buffer_offset + _string_start, _buffer_offset + _string_end));
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
            
            _line_is_option = false;
            _find_indent    = true;
            _in_comment     = false;
            _in_metadata    = false;
            
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
                
                if ((_byte == ord("-")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord(">")))
                {
                    // -> option
                    buffer_seek(_buffer, buffer_seek_relative, 1);
                    
                    //Skip over whitespace
                    while(buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == 0x20) buffer_seek(_buffer, buffer_seek_relative, 1);
                    
                    _string_start = buffer_tell(_buffer);
                    _string_end   = _string_start-1;
                    
                    _type = "option";
                }
                else
                {
                    //Re-parse this byte
                    buffer_seek(_buffer, buffer_seek_relative, -1);
                }
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
            else if (!_in_action && (_byte == ord("/")) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("/"))) //   //
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
                
                _type = _line_is_option? "option" : "text";
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
