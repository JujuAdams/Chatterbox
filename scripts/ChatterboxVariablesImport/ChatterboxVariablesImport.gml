/// Replaces all Chatterbox variables with values found in the given string
/// The string passed into this function should have been created by ChatterboxVariablesExport()
/// 
/// @param string

function ChatterboxVariablesImport(_string)
{
    var _json = json_decode(_string);
    if (_json < 0)
    {
        __ChatterboxError("JSON string failed to decode");
        exit;
    }
    
    ds_map_destroy(global.chatterboxVariablesMap);
    global.chatterboxVariablesMap = _json;
}