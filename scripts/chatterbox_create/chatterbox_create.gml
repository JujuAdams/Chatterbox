/// Creates a chatterbox
/// 
/// @param [filename]

function chatterbox_create()
{
	var _filename = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : global.__chatterbox_default_file;
    return new __chatterbox_class(_filename);
}