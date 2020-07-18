/// Creates a Chatterbox host
/// 
/// Chatterbox uses a "host" to keep track of various bits of data.
/// Hosts are structs and, as a result, are automatically cleaned up by GameMaker without needing to be explicitly destroyed
/// 
/// @param [filename]

function chatterbox_create_host() 
{
	var _filename = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : global.__chatterbox_default_file;
    
	if (!is_string(_filename))
	{
	    __chatterbox_error("Source files must be strings (Got \"" + string(_filename) + "\")");
	    return undefined;
	}
    
	if (!ds_map_exists(global.__chatterbox_file_data, _filename))
	{
	    __chatterbox_error("Cannot find \"" + _filename + "\"");
	    return undefined;
	}
    
    return new __chatterbox_class_host(_filename);
}