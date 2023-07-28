// Feather disable all
/// Loads a Yarn source for use with Chatterbox directly from a string
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param aliasName  Alias to refer to this content (effectively a fake filename)
/// @param string     String to read

function ChatterboxLoadFromString(_filename, _string)
{
    //Write the string directly into a buffer we can use for parsing
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _string);
    buffer_seek(_buffer, buffer_seek_start, 0);
    
    //Create a struct that represents this source
    ChatterboxLoadFromBuffer(_filename, _buffer);
    
    //No! Memory! Leaks!
    buffer_delete(_buffer);
}
