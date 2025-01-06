// Feather disable all

/// Loads a ChatterScript source for use with Chatterbox directly from a string
///
/// @param aliasName  Alias to refer to this content (effectively a fake filename)
/// @param string     String to read

function ChatterboxLoadFromString(_aliasName, _string)
{
    static _system = __ChatterboxSystem();
    
    _aliasName = __ChatterboxReplaceBackslashes(_aliasName);
    
    //Write the string directly into a buffer we can use for parsing
    var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _string);
    buffer_seek(_buffer, buffer_seek_start, 0);
    
    //Create a struct that represents this source
    ChatterboxLoadFromBuffer(_aliasName, _buffer);
    
    //No! Memory! Leaks!
    buffer_delete(_buffer);
}
