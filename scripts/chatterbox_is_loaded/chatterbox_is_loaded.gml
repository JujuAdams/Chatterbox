/// Returns if the given source file has been loaded
///
/// @param filename  Name of the file to check

function chatterbox_is_loaded(_filename)
{
    var _value = variable_struct_get(global.chatterbox_files, _filename);
    if (_value == undefined) return false;
    return _value;
}