/// Unloads a specific source file from Chatterbox
///
/// @param filename  Name of the file to unload

function chatterbox_unload(_filename)
{
    if (ds_map_exists(global.chatterbox_files, _filename))
    {
        var _file = global.chatterbox_files[? _filename];
        if (_file.loaded)
        {
            _file.loaded = false;
            ds_map_delete(global.chatterbox_files, _filename);
            if (__CHATTERBOX_DEBUG_LOADER) __chatterbox_trace("\"", _filename, "\" unloaded");
        }
    }
}