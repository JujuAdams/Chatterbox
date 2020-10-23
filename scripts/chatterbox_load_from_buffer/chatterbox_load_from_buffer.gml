/// Loads a Yarn source for use with Chatterbox directly from a buffer (formatted as either a .yarn or .json file)
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param filename  Filename to use for this buffer
/// @param buffer    Buffer to read

function chatterbox_load_from_buffer(_filename, _buffer)
{
    if (!is_string(_filename))
    {
        __chatterbox_error("Buffers should have a filename specified as a string.\n(Input was an invalid datatype)");
        return undefined;
    }
    
    if (chatterbox_is_loaded(_filename))
    {
        //Unload what we have already if needed
        //This will invalidate any chatterboxes that currently exist and are using the file
        chatterbox_unload(_filename);
    }
    
    //Set our default file if we don't already have one
    if (global.__chatterbox_default_file == "") global.__chatterbox_default_file = _filename;
    
    //Create a struct that represents this source
    var _source = new __chatterbox_class_source(_filename, _buffer);
    
    //If we successfully decoded a buffer add it to our collection of chatterboxes
    if ((instanceof(_source) == "__chatterbox_class_source") && !is_undefined(_source.format))
    {
        global.chatterbox_files[? _filename] = _source;
    }
}