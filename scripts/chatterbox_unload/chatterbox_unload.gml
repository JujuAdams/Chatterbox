/// Unloads a specific source file from Chatterbox
///
/// @param filename  Name of the file to unload

function chatterbox_unload(_filename)
{
    if (variable_struct_exists(global.chatterbox_files, _filename))
    {
        variable_struct_set(global.chatterbox_files, _filename, undefined);
        if (__CHATTERBOX_DEBUG_LOADER) __chatterbox_trace("\"", _filename, "\" unloaded");
    }
}