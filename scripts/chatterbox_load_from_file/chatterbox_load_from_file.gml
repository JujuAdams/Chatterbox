/// Loads a Yarn file (either .yarn or .json) for use with Chatterbox
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param filename  Name of the file to add

function chatterbox_load_from_file(_filename)
{
    if (!is_string(_filename))
    {
        __chatterbox_error("Files should be loaded using their filename as a string.\n(Input was an invalid datatype)");
        return undefined;
    }
    
    //Fix the font directory name if it's weird
    var _font_directory = CHATTERBOX_SOURCE_DIRECTORY;
    var _char = string_char_at(_font_directory , string_length(_font_directory ));
    if (_char != "\\") && (_char != "/") _font_directory += "\\";
    
    if (!file_exists(_font_directory + _filename))
    {
        __chatterbox_error("\"", _filename, "\" could not be found");
        return undefined;
    }
    
    if (os_browser == browser_not_a_browser)
    {
        var _buffer = buffer_load(_font_directory + _filename);
    }
    else
    {
        __chatterbox_trace("Using legacy file loading method on HTML5");
        
        var _file = file_text_open_read(_font_directory + _filename);
        
        var _string = "";
        while(!file_text_eof(_file)) _string += file_text_readln(_file);
        file_text_close(_file);
        
        var _buffer = buffer_create(string_byte_length(_string), buffer_fixed, 1);
        buffer_write(_buffer, buffer_text, _string);
        buffer_seek(_buffer, buffer_seek_start, 0);
        
        show_debug_message(_string);
    }
    
    return chatterbox_load_from_buffer(_filename, _buffer);
}