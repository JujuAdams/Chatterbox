/// @param string

function __chatterbox_class_text(_string) constructor
{
    raw_string = _string;
    substrings = [];
    
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _string);
    buffer_seek(_buffer, buffer_seek_start, 0);
    
    //Set up state
    var _string_start  = 0;
    var _in_expression = false;
    
    //Iterate over every byte in the buffer
    repeat(buffer_get_size(_buffer))
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        if (_byte == 0x00)
        {
            //We've hit a null, add everything before it to the substring array as a simple string
            buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x0);
            buffer_seek(_buffer, buffer_seek_start, _string_start);
            
            var _substring = buffer_read(_buffer, buffer_string);
            
            array_push(substrings, _substring);
        }
        else if (_byte == ord("{")) //GameMaker will optimise this at compile time
        {
            //Check to see if this character is escaped
            if (buffer_peek(_buffer, buffer_tell(_buffer)-2, buffer_u8) != ord("\\"))
            {
                //We've hit a sub-expression, add everything before it to the substring array as a simple string
                buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x0);
                buffer_seek(_buffer, buffer_seek_start, _string_start);
                var _substring = buffer_read(_buffer, buffer_string);
                
                array_push(substrings, _substring);
                
                _in_expression = true;
                _string_start = buffer_tell(_buffer);
            }
        }
        else if (_in_expression && (_byte == ord("}")))
        {
            //Check to see if this character is escaped
            if (buffer_peek(_buffer, buffer_tell(_buffer)-2, buffer_u8) != ord("\\"))
            {
                //We've hit a sub-expression, add everything before it to the substring array as a simple string
                buffer_poke(_buffer, buffer_tell(_buffer)-1, buffer_u8, 0x0);
                buffer_seek(_buffer, buffer_seek_start, _string_start);
                var _substring = buffer_read(_buffer, buffer_string);
                
                var _expression = __chatterbox_parse_expression(_substring, false);
                array_push(substrings, _expression);
                
                _in_expression = false;
                _string_start = buffer_tell(_buffer);
            }
        }
        else if ((_byte == ord("/")) //Standard comment // syntax
             &&  (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == ord("/"))
             &&  (buffer_peek(_buffer, buffer_tell(_buffer)-2, buffer_u8) != ord("\\")))
        {
            //Hit a comment
            break;
        }
    }
    
    buffer_delete(_buffer);
    
    static evaluate = function(_local_scope, _filename)
    {
        var _result = "";
        
        var _i = 0;
        repeat(array_length(substrings))
        {
            var _value = substrings[_i];
            if (is_struct(_value)) _value = __chatterbox_evaluate(_local_scope, _filename, _value, undefined);
            _result += string(_value);
            ++_i;
        }
        
        return _result;
    }
}