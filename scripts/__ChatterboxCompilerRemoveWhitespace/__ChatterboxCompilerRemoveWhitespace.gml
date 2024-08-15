// Feather disable all

/// @param string
/// @param leading

function __ChatterboxCompilerRemoveWhitespace(_string, _leading)
{
    global.__chatterboxIndentSize = 0;
    
    var _result = _string;
    
    if ((_leading == true) || (_leading == all))
    {
        var _i = 1;
        repeat(string_length(_result))
        {
            var _ord = ord(string_char_at(_result, _i));
            if (_ord  > 32) break;
            if (_ord == 32) global.__chatterboxIndentSize++;
            if (_ord ==  9) global.__chatterboxIndentSize += CHATTERBOX_INDENT_TAB_SIZE;
            _i++;
        }
        
        _result = string_delete(_result, 1, _i-1);
    }
    
    if ((_leading == false) || (_leading == all))
    {
        var _i = string_length(_result);
        repeat(string_length(_result))
        {
            var _ord = ord(string_char_at(_result, _i));
            if (_ord  > 32) break;
            if (_ord == 32) global.__chatterboxIndentSize++;
            if (_ord ==  9) global.__chatterboxIndentSize += CHATTERBOX_INDENT_TAB_SIZE;
            _i--;
        }
        
        _result = string_copy(_result, 1, _i);
    }
    
    return _result;
}