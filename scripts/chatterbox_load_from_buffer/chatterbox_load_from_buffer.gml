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
    
    //Read a string from the buffer
    var _old_tell = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_seek(_buffer, buffer_seek_start, _old_tell);
    
    //Create a struct that represents this source
    var _source = new __chatterbox_class_source(_filename, _string);
    
    //If we successfully decoded a buffer add it to our collection of chatterboxes
    if ((instanceof(_source) == "__chatterbox_class_source") && _source.loaded)
    {
        global.chatterbox_files[? _filename] = _source;
    }
}