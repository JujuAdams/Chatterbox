// Feather disable all
function __ChatterboxClassLine() constructor
{
    __substring_array      = [];
    __text_substring_array = [];
    __hash_substring_array = [];
    __hash_array           = [];
    
    static __Push = function(_substring)
    {
        switch(_substring.type)
        {
            case "text":
            case "option":
                array_push(__text_substring_array, _substring);
            break;
            
            case "metadata":
                //Filter for hash metadata
                var _text = _substring.text;
                if (__ChatterboxMetadataStringIsLineHash(_text))
                {
                    array_push(__hash_substring_array, _substring);
                    array_push(__hash_array, string_delete(_text, 1, __CHATTERBOX_LINE_HASH_PREFIX_LENGTH));
                }
            break;
        }
        
        array_push(__substring_array, _substring);
    }
    
    static __Size = function()
    {
        return array_length(__text_substring_array);
    }
    
    static __BuildLocalisation = function(_hash_order, _hash_dict, _buffer_batch)
    {
        if (array_length(__text_substring_array) > array_length(__hash_array))
        {
            var _last_buffer_pos = -infinity;
            var _i = 0;
            repeat(array_length(__substring_array))
            {
                _last_buffer_pos = max(_last_buffer_pos, __substring_array[_i].buffer_end+1);
                ++_i;
            }
            
            var _i = array_length(__hash_array);
            repeat(array_length(__text_substring_array) - array_length(__hash_array))
            {
                //Make a new hash for the textual substring
                var _hash = string_copy(md5_string_unicode(string(__ChatterboxXORShiftRandom())), 1, CHATTERBOX_LINE_HASH_SIZE);
                array_push(__hash_array, _hash);
                
                //Add new localisation hashes
                _buffer_batch.__Insert(_last_buffer_pos, " #line:", _hash);
                
                ++_i;
            }
        }
        else if (array_length(__text_substring_array) < array_length(__hash_array))
        {
            //Remove extra localisation hashes
            var _i = array_length(__text_substring_array)-1;
            repeat(array_length(__hash_array) - array_length(__text_substring_array))
            {
                var _substring = __hash_substring_array[_i];
                _buffer_batch.__Delete(_substring.buffer_start-1, 1 + _substring.buffer_end - (_substring.buffer_start-1));
                ++_i;
            }
        }
        
        //Pair up hashes with text strings
        var _i = 0;
        repeat(array_length(__text_substring_array))
        {
            var _hash = __hash_array[_i];
            array_push(_hash_order, _hash);
            _hash_dict[$ _hash] = __text_substring_array[_i].text;
            ++_i;
        }
    }
}
