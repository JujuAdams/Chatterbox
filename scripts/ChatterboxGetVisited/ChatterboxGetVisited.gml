// Feather disable all
/// @param nodeTitle
/// @param filename

function ChatterboxGetVisited(_node_title, _filename)
{
    static _system = __ChatterboxSystem();
    
    if (string_pos(":", _node_title) > 0)
    {
        //We have a colon, the name is a filename:node reference
        var _key = "visited(" + string(_node_title) + ")";
    }
    else
    {
        if (_filename == undefined) __ChatterboxError("Filename must be specified");
        
        //No colon, presume the given name is a node
        var _key = "visited(" + string(_filename) + CHATTERBOX_FILENAME_SEPARATOR + string(_node_title) + ")";
    }
    
    var _value = _system.__variablesMap[? _key];
    if (_value == undefined) return 0;
    return _value;
}
