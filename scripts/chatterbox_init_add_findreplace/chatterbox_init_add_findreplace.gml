///
/// <<hammertime>>
/// <<stop>>
///
/// @param oldString
/// @param newString
function chatterbox_init_add_findreplace(argument0, argument1) {

	if ( !variable_global_exists("__chatterbox_init_complete") )
	{
	    __chatterbox_error("chatterboc_init_findreplace() should be called after chatterbox_init_start()");
	    return false;
	}

	if (global.__chatterbox_init_complete)
	{
	    __chatterbox_error("chatterboc_init_findreplace() should be called before chatterbox_init_end()");
	    return false;
	}

	ds_list_add(global.__chatterbox_findreplace_old_string, argument0);
	ds_list_add(global.__chatterbox_findreplace_new_string, argument1);

	return true;


}
