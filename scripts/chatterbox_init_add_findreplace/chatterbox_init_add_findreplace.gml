///
/// <<hammertime>>
/// <<stop>>
///
/// @param oldString
/// @param newString

if ( !variable_global_exists("__chatterbox_init_complete") )
{
    __chatterbox_error("chatterboc_init_findreplace() should be called after chatterbox_init_start()\n ", true);
    return false;
}

if (global.__chatterbox_init_complete)
{
    __chatterbox_error("chatterboc_init_findreplace() should be called before chatterbox_init_end()\n ", true);
    return false;
}

ds_list_add(global.__chatterbox_findreplace_old_string, argument0);
ds_list_add(global.__chatterbox_findreplace_new_string, argument1);

return true;