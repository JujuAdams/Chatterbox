// Feather disable all

/// @param identifier
/// @param nodeTitle
/// @param filename

function __ChatterboxLocalCounter(_identifier, _node_title, _filename)
{
    static _system = __ChatterboxSystem();
    
    if (string_pos(CHATTERBOX_FILENAME_SEPARATOR, _node_title) > 0)
    {
        //We have a colon, the name is a filename:node reference
        var _key = "localCounter(" + string(_identifier) + "@" + string(_node_title) + ")";
    }
    else
    {
        if (_filename == undefined) __ChatterboxError("Filename must be specified");
        
        //No colon, presume the given name is a node
        var _key = "localCounter(" + string(_identifier) + "@" + string(_filename) + CHATTERBOX_FILENAME_SEPARATOR + string(_node_title) + ")";
    }
    
    var _value = _system.__variablesMap[? _key];
    if (_value == undefined)
    {
        _value = 1;
    }
    else
    {
        _value++;
    }
    
    _system.__variablesMap[? _key] = _value;
    
    return _value;
}
