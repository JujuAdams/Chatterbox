/// @param nodeTitle
/// @param [filename]

function ChatterboxGetVisited()
{
    var _node_title = argument[0];
    var _filename   = ((argument_count > 1) && is_string(argument[1]))? argument[1] : "";
    
    if (string_pos(":", _node_title) > 0)
    {
        //We have a colon, the name is a filename:node reference
        var _key = "visited(" + string(_node_title) + ")";
    }
    else
    {
        //No colon, presume the given name is a node
        var _key = "visited(" + string(_filename) + CHATTERBOX_FILENAME_SEPARATOR + string(_node_title) + ")";
    }
    
    var _value = global.chatterboxVariablesMap[? _key];
    if (_value == undefined) return 0;
    return _value;
}