/// Resets the visited state of every node
/// Future calls to Chatterbox's "visited()" function for all nodes will return 0

function ChatterboxVariablesClearVisitedAll()
{
    var _i = 0;
    repeat(ds_list_size(CHATTERBOX_VARIABLES_LIST))
    {
        var _key = CHATTERBOX_VARIABLES_LIST[| _i];
        if (string_copy(_key, 1, 8) == "visited(")
        {
            ds_map_delete(CHATTERBOX_VARIABLES_MAP, _key);
            ds_list_delete(CHATTERBOX_VARIABLES_LIST, _i);
        }
        else
        {
            ++_i;
        }
    }
}