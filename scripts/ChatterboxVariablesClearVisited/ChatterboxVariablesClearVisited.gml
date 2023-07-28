// Feather disable all
/// Resets the visited state of a specific node in a specific file
/// Future calls to Chatterbox's "visited()" function for this node will return 0
/// 
/// @param name       Name of the node to "unvisit"
/// @param filename   Alias of the filename that the node can be found in

function ChatterboxVariablesClearVisited(_node, _filename)
{
    var _variable = "visited(" + string(_filename) + CHATTERBOX_FILENAME_SEPARATOR + string(_node) + ")";
    var _index = ds_list_find_index(global.__chatterboxVariablesList, _variable);
    if (_index >= 0) ds_list_delete(global.__chatterboxVariablesList, _variable);
    ds_map_delete(global.__chatterboxVariablesMap, _variable);
}
