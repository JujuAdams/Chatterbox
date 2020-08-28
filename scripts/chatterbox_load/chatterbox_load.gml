/// Loads a Yarn file (either .yarn or .json) for use with Chatterbox
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param filename  Name of the file to add

function chatterbox_load(_filename)
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
    
    return chatterbox_load_from_buffer(_filename, buffer_load(_font_directory + _filename));
}