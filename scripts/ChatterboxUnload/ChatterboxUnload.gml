// Feather disable all
/// Unloads a specific source file from Chatterbox
///
/// @param filename  Name of the file to unload

function ChatterboxUnload(_filename)
{
    if (ds_map_exists(global.chatterboxFiles, _filename))
    {
        var _file = global.chatterboxFiles[? _filename];
        if (_file.loaded)
        {
            _file.loaded = false;
            ds_map_delete(global.chatterboxFiles, _filename);
            if (__CHATTERBOX_DEBUG_LOADER) __ChatterboxTrace("\"", _filename, "\" unloaded");
        }
    }
}
