// Feather disable all
/// Resets the visited state of a specific node in a specific file
/// Future calls to Chatterbox's "visited()" function for this node will return 0
/// 
/// @param name       Name of the node to "unvisit"
/// @param filename   Alias of the filename that the node can be found in

function ChatterboxVariablesClearVisited(_node, _filename)
{
    static _system = __ChatterboxSystem();
    
    var _variable = "visited(" + string(_filename) + CHATTERBOX_FILENAME_SEPARATOR + string(_node) + ")";
    var _index = ds_list_find_index(_system.__variablesList, _variable);
    if (_index >= 0) ds_list_delete(_system.__variablesList, _variable);
    ds_map_delete(_system.__variablesMap, _variable);
}
