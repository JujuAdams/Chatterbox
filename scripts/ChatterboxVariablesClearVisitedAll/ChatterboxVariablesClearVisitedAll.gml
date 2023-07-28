// Feather disable all
/// Resets the visited state of every node
/// Future calls to Chatterbox's "visited()" function for all nodes will return 0

function ChatterboxVariablesClearVisitedAll()
{
    var _i = 0;
    repeat(ds_list_size(global.__chatterboxVariablesList))
    {
        var _key = global.__chatterboxVariablesList[| _i];
        if (string_copy(_key, 1, 8) == "visited(")
        {
            ds_map_delete(global.__chatterboxVariablesMap, _key);
            ds_list_delete(global.__chatterboxVariablesList, _i);
        }
        else
        {
            ++_i;
        }
    }
}
