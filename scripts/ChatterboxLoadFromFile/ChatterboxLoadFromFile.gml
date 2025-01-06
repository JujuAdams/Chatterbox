// Feather disable all

/// Loads a ChatterScript file (either .chatter or .json) for use with Chatterbox
///
/// @param path         Path to the file to add, relative to CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY
/// @param [aliasName]  Alias for this file (overwrites the filename with whatever you provide)

function ChatterboxLoadFromFile(_path, _aliasName = _path)
{
    static _system = __ChatterboxSystem();
    
    _aliasName = __ChatterboxReplaceBackslashes(_aliasName);
    
    if (!is_string(_path))
    {
        __ChatterboxError("Files should be loaded using their filename as a string\n(Input was an invalid datatype)");
        return undefined;
    }
    
    if (!is_string(_aliasName))
    {
        __ChatterboxError("Aliases for filenames should be a string\n(Input was an invalid datatype)");
        return undefined;
    }
    
    _path = _system.__directory + _path;
    
    if (!file_exists(_path))
    {
        __ChatterboxError("\"", _path, "\" could not be found\nCheck the filename and CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY");
        return undefined;
    }
    
    if (os_browser == browser_not_a_browser)
    {
        var _buffer = buffer_load(_path);
        var _result = ChatterboxLoadFromBuffer(_aliasName, _buffer);
        buffer_delete(_buffer);
        
        return _result;
    }
    else
    {
        __ChatterboxTrace("Warning! Using legacy file loading method on HTML5");
        
        var _file = file_text_open_read(_path);
        var _string = "";
        while(!file_text_eof(_file)) _string += file_text_readln(_file);
        file_text_close(_file);
        
        return ChatterboxLoadFromString(_aliasName, _string);
    }
}
