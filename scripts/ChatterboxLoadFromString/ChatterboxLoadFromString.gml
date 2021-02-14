/// Loads a Yarn source for use with Chatterbox directly from a string
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param filename  Filename to use for this buffer
/// @param string    String to read

function ChatterboxLoadFromString(_filename, _string)
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
    if (global.__chatterbox_default_file == "") global.__chatterbox_default_file = _filename;
    
    //Create a struct that represents this source
    var _source = new __ChatterboxClassSource(_filename, _string);
    
    //If we successfully decoded a buffer add it to our collection of chatterboxes
    if ((instanceof(_source) == "__ChatterboxClassSource") && _source.loaded)
    {
        global.chatterbox_files[? _filename] = _source;
    }
}