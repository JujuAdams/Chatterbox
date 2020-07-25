/// @param node

function __chatterbox_mark_visited(_node)
{
    with(_node)
    {
        var _long_name = "visited(" + string(filename) + CHATTERBOX_FILENAME_SEPARATOR + string(title) + ")";
        
        var _value = CHATTERBOX_VARIABLES_MAP[? _long_name];
        if (_value == undefined)
        {
            CHATTERBOX_VARIABLES_MAP[? _long_name] = 1;
        }
        else
        {
            CHATTERBOX_VARIABLES_MAP[? _long_name]++;
        }
        
        __chatterbox_trace(json_encode(CHATTERBOX_VARIABLES_MAP));
    }
}