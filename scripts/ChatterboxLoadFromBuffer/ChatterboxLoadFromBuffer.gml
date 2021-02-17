/// Loads a Yarn source for use with Chatterbox directly from a buffer (formatted as either a .yarn or .json file)
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param aliasName  Alias to use for this buffer
/// @param buffer     Buffer to read

function ChatterboxLoadFromBuffer(_filename, _buffer)
{
    if (!is_string(_filename))
    {
        __ChatterboxError("Buffers should have a filename specified as a string.\n(Input was an invalid datatype)");
        return undefined;
    }
    
    if (ChatterboxIsLoaded(_filename))
    {
        //Unload what we have already if needed
        //This will invalidate any chatterboxes that currently exist and are using the file
        ChatterboxUnload(_filename);
    }
    
    //Set our default file if we don't already have one
    if (global.__chatterboxDefaultFile == "") global.__chatterboxDefaultFile = _filename;
    
    //Read a string from the buffer
    var _old_tell = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_seek(_buffer, buffer_seek_start, _old_tell);
    
    //Create a struct that represents this source
    var _source = new __ChatterboxClassSource(_filename, _string);
    
    //If we successfully decoded a buffer add it to our collection of chatterboxes
    if ((instanceof(_source) == "__ChatterboxClassSource") && _source.loaded)
    {
        global.chatterboxFiles[? _filename] = _source;
    }
}