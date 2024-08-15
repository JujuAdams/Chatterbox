// Feather disable all
/// Resets the visited state of every node
/// Future calls to Chatterbox's "visited()" function for all nodes will return 0

function ChatterboxVariablesClearVisitedAll()
{
    static _system = __ChatterboxSystem();
    
    var _i = 0;
    repeat(ds_list_size(_system.__variablesList))
    {
        var _key = _system.__variablesList[| _i];
        if (string_copy(_key, 1, 8) == "visited(")
        {
            ds_map_delete(_system.__variablesMap, _key);
            ds_list_delete(_system.__variablesList, _i);
        }
        else
        {
            ++_i;
        }
    }
}
