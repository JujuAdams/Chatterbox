// Feather disable all
/// Replaces a portion of Chatterbox script with a different portion of text
/// This is performed before any compilation or parsing so can be used to insert commands into your scripts
///
/// @param oldString   The old string to replace
/// @param newString   The new string to insert in place of the old string

function ChatterboxAddFindReplace(_old, _new)
{
    static _system = __ChatterboxSystem();
    
    ds_list_add(_system.__findReplaceOldString, _old);
    ds_list_add(_system.__findReplaceNewString, _new);
}
