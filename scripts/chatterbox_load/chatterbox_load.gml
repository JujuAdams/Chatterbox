/// Loads a Yarn file (either .yarn or .json) for use with Chatterbox
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param fileName  Name of the file to add

function chatterbox_load(_filename)
{
	if (chatterbox_is_loaded(_filename))
	{
	    __chatterbox_error("\"" + _filename + "\" has already been loaded");
	    return undefined;
	}
    
	if (!is_string(_filename))
	{
	    __chatterbox_error("Files should be loaded using their filename as a string.\n(Input was an invalid datatype)");
	    return undefined;
	}
    
	if (global.__chatterbox_default_file == "") global.__chatterbox_default_file = _filename;
    var _file = new __chatterbox_class_file(_filename);
    
    if (instanceof(_file) == "__chatterbox_class_file")
    {
        with(_file)
        {
            variable_struct_set(global.chatterbox_files, filename, self);
            __chatterbox_trace("Added \"", filename, "\" as a source file named \"", name, "\" (format=\"", format, "\")");
        }
    }
}