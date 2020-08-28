/// Unloads a specific source file from Chatterbox
///
/// @param filename  Name of the file to unload

function chatterbox_unload(_filename)
{
    var _file = variable_struct_get(global.chatterbox_files, _filename);
    if (instanceof(_file) == "__chatterbox_class_source")
    {
        if (_file.loaded)
        {
            _file.loaded = false;
            variable_struct_set(global.chatterbox_files, _filename, undefined);
            if (__CHATTERBOX_DEBUG_LOADER) __chatterbox_trace("\"", _filename, "\" unloaded");
        }
    }
}