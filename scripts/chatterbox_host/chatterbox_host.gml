/// Creates a Chatterbox host
/// 
/// Chatterbox uses a "host" to keep track of various bits of data.
/// Hosts are structs and, as a result, are automatically cleaned up by GameMaker without needing to be explicitly destroyed
/// 
/// @param [filename]

function chatterbox_host() constructor
{
	var _filename = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : global.__chatterbox_default_file;
    
	if (!is_string(_filename))
	{
	    __chatterbox_error("Source files must be strings (got \"" + string(_filename) + "\")");
	    return undefined;
	}
    
	if (!chatterbox_is_loaded(_filename))
	{
	    __chatterbox_error("\"" + _filename + "\" has not been loaded");
	    return undefined;
	}
    
    filename = _filename;
    title    = undefined;
    children = [];
}