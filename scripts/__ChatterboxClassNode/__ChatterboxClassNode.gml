/// @param filename
/// @param nodeTags
/// @param bodyString
/// @param applyStringReplacement
/// @param buffer
/// @param bufferStart
/// @param bufferEnd

function __ChatterboxClassNode(_filename, _node_metadata, _apply_string_replacement, _buffer, _buffer_start, _buffer_end) constructor
{
    filename         = _filename;
    title            = _node_metadata.title;
    metadata         = _node_metadata;
    root_instruction = new __ChatterboxClassInstruction(undefined, -1, 0);
    
    if (__CHATTERBOX_DEBUG_COMPILER) __ChatterboxTrace("[", title, "]");
    
    var _substring_array = __ChatterboxSplitBody(_buffer, _buffer_start, _buffer_end, _apply_string_replacement);
    __ChatterboxCompile(_substring_array, root_instruction);
    
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
}