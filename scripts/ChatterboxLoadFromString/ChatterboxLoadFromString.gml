/// Loads a Yarn source for use with Chatterbox directly from a string
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param aliasName  Alias to refer to this content (effectively a fake filename)
/// @param string     String to read

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
    if (global.__chatterboxDefaultFile == "") global.__chatterboxDefaultFile = _filename;
	
	//Write the string directly into a buffer we can use for parsing
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _string);
    buffer_seek(_buffer, buffer_seek_start, 0);
	
    //Create a struct that represents this source
    var _source = new __ChatterboxClassSource(_filename, _buffer);
	
	//No! Memory! Leaks!
    buffer_delete(_buffer);
    
    //If we successfully decoded a buffer add it to our collection of chatterboxes
    if ((instanceof(_source) == "__ChatterboxClassSource") && _source.loaded)
    {
        global.chatterboxFiles[? _filename] = _source;
    }
}