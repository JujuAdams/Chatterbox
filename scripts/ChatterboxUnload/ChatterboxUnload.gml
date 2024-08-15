// Feather disable all
/// Unloads a specific source file from Chatterbox
///
/// @param aliasName

function ChatterboxUnload(_aliasName)
{
    static _system = __ChatterboxSystem();
    
    _aliasName = __ChatterboxReplaceBackslashes(_aliasName);
    
    if (ds_map_exists(_system.__files, _aliasName))
    {
        var _file = _system.__files[? _aliasName];
        if (_file.loaded)
        {
            _file.loaded = false;
            ds_map_delete(_system.__files, _aliasName);
            if (__CHATTERBOX_DEBUG_LOADER) __ChatterboxTrace("\"", _aliasName, "\" unloaded");
        }
    }
}
