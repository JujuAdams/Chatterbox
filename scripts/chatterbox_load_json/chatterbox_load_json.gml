/// Loads a Yarn .json file for use with Chatterbox
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param fileName  Name of the Yarn .json file to add

function chatterbox_load_json(_filename)
{
	if (chatterbox_is_loaded(_filename))
	{
	    __chatterbox_error("\"" + _filename + "\" has already been loaded");
	    return undefined;
	}
    
	if (!is_string(_filename))
	{
	    __chatterbox_error("Source files should be initialised using their filename as a string.\n(Input was an invalid datatype)");
	    return undefined;
	}
    
	if (global.__chatterbox_default_file == "") global.__chatterbox_default_file = _filename;
    var _ = new __chatterbox_class_file(_filename, _filename, "json");
}