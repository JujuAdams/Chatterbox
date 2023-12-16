// Feather disable all
/// Unloads a specific source file from Chatterbox
///
/// @param aliasName

function ChatterboxUnload(_aliasName)
{
    _aliasName = __ChatterboxReplaceBackslashes(_aliasName);
    
    if (ds_map_exists(global.chatterboxFiles, _aliasName))
    {
        var _file = global.chatterboxFiles[? _aliasName];
        if (_file.loaded)
        {
            _file.loaded = false;
            ds_map_delete(global.chatterboxFiles, _aliasName);
            if (__CHATTERBOX_DEBUG_LOADER) __ChatterboxTrace("\"", _aliasName, "\" unloaded");
        }
    }
}
