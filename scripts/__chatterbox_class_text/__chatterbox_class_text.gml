/// @param string

function __chatterbox_class_text(_string) constructor
{
    raw_string = _string;
    substrings = [];
    
    //TODO
    substrings[@ 0] = _string;
    
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