// Feather disable all
/// @param filename
/// @param nodeTags
/// @param bodyString
/// @param compile
/// @param buffer
/// @param bufferStart
/// @param bufferEnd

function __ChatterboxClassNode(_filename, _node_metadata, _compile, _buffer, _buffer_start, _buffer_end) constructor
{
    filename         = _filename;
    title            = _node_metadata.title;
    metadata         = _node_metadata;
    compile          = _compile;
    buffer           = _buffer;
    buffer_start     = _buffer_start;
    buffer_end       = _buffer_end;
    root_instruction = undefined;
    substring_array  = undefined;
    
    if (__CHATTERBOX_DEBUG_COMPILER) __ChatterboxTrace("[", title, "]");
    
    var _substring_array = __ChatterboxSplitBody(buffer, buffer_start, buffer_end, compile);
    
    if (compile)
    {
        root_instruction = new __ChatterboxClassInstruction(undefined, -1, 0);
        __ChatterboxCompile(_substring_array, root_instruction, filename + ":" + title + ":#");
    }
    else
    {
        substring_array = _substring_array;
    }
    
    static MarkVisited = function()
    {
        var _long_name = "visited(" + string(filename) + CHATTERBOX_FILENAME_SEPARATOR + string(title) + ")";
        
        var _value = global.__chatterboxVariablesMap[? _long_name];
        if (_value == undefined)
        {
            global.__chatterboxVariablesMap[? _long_name] = 1;
        }
        else
        {
            global.__chatterboxVariablesMap[? _long_name]++;
        }
    }
    
    static toString = function()
    {
        return "Node " + string(filename) + CHATTERBOX_FILENAME_SEPARATOR + string(title);
    }
    
    static __BuildLocalisation = function(_node_order, _node_dict, _buffer_batch)
    {
        array_push(_node_order, title);
        
        var _hash_order = [];
        var _hash_dict  = {};
        
        _node_dict[$ title] = {
            order: _hash_order,
            strings: _hash_dict,
        };
        
        //Collect substrings together into lines
        var _lines_array = [];
        var _current_line_number = undefined;
        var _current_line = new __ChatterboxClassLine();
        
        var _i = 0;
        repeat(array_length(substring_array))
        {
            var _substring_struct = substring_array[_i];
            if (_substring_struct.line != _current_line_number)
            {
                if (_current_line.__Size() > 0) array_push(_lines_array, _current_line);
                _current_line_number = _substring_struct.line;
                _current_line = new __ChatterboxClassLine();
            }
            
            _current_line.__Push(_substring_struct);
            ++_i;
        }
        
        if (_current_line.__Size() > 0) array_push(_lines_array, _current_line);
        
        //Build localisation for each line
        var _i = 0;
        repeat(array_length(_lines_array))
        {
            _lines_array[_i].__BuildLocalisation(_hash_order, _hash_dict, _buffer_batch);
            ++_i;
        }
    }
}
