/// Loads a Yarn file (either .yarn or .json) for use with Chatterbox
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param path         Path to the file to add; relative to CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY
/// @param [aliasName]  Alias for this file

function ChatterboxLoadFromFile()
{
    var _path      = argument[0];
    var _aliasName = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : filename_name(_path);
    
    if (!is_string(_path))
    {
        __ChatterboxError("Files should be loaded using their filename as a string.\n(Input was an invalid datatype)");
        return undefined;
    }
    
    if (!is_string(_aliasName))
    {
        __ChatterboxError("Aliases for filenames should be a string.\n(Input was an invalid datatype)");
        return undefined;
    }
    
    _path = global.__chatterboxDirectory + _path;
    
    if (!file_exists(_path))
    {
        __ChatterboxError("\"", _path, "\" could not be found\nCheck the filename, and that CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY is correct");
        return undefined;
    }
    
    if (os_browser == browser_not_a_browser)
    {
        var _buffer = buffer_load(_path);
        return ChatterboxLoadFromBuffer(_aliasName, _buffer);
    }
    else
    {
        __ChatterboxTrace("Using legacy file loading method on HTML5");
        
        var _file = file_text_open_read(_path);
        var _string = "";
        while(!file_text_eof(_file)) _string += file_text_readln(_file);
        file_text_close(_file);
        
        return ChatterboxLoadFromString(_aliasName, _string);
    }
}