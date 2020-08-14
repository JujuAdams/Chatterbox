/// <<hammertime>>
/// <<stop>>
///
/// @param oldString
/// @param newString

function chatterbox_add_findreplace(_old, _new)
{
    ds_list_add(global.__chatterbox_findreplace_old_string, _old);
    ds_list_add(global.__chatterbox_findreplace_new_string, _new);
}