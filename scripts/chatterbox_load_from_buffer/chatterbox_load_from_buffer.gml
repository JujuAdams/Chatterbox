/// Loads a Yarn source for use with Chatterbox directly from a buffer (formatted as either a .yarn or .json file)
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param filename  Filename to use for this buffer
/// @param buffer    Buffer to read

function chatterbox_load_from_buffer(_filename, _buffer)
{
    if (variable_struct_exists(global.chatterbox_files, _filename))
    {
        __chatterbox_trace("\"" + _filename + "\" has already been loaded");
        return undefined;
    }
    
    if (!is_string(_filename))
    {
        __chatterbox_error("Files should be loaded using their filename as a string.\n(Input was an invalid datatype)");
        return undefined;
    }
    
    //Set our default file if we don't already have one
    if (global.__chatterbox_default_file == "") global.__chatterbox_default_file = _filename;
    
    //Create a struct that represents this source
    var _source = new __chatterbox_class_source(_filename, _buffer);
    
    //If we successfully decoded a buffer add it to our collection of chatterboxes
    if ((instanceof(_source) == "__chatterbox_class_source") && !is_undefined(_source.format))
    {
        variable_struct_set(global.chatterbox_files, _filename, _source);
    }
}