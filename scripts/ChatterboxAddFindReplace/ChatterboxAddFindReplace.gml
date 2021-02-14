/// <<hammertime>>
/// <<stop>>
///
/// @param oldString
/// @param newString

function ChatterboxAddFindReplace(_old, _new)
{
    ds_list_add(global.__chatterboxFindReplaceOldString, _old);
    ds_list_add(global.__chatterboxFindReplaceNewString, _new);
}