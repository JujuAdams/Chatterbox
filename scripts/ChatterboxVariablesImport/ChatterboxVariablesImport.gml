// Feather disable all
/// Replaces all Chatterbox variables with values found in the given string
/// The string passed into this function should have been created by ChatterboxVariablesExport()
/// 
/// @param string

function ChatterboxVariablesImport(_string)
{
    static _system = __ChatterboxSystem();
    
    var _json = json_decode(_string);
    if (_json < 0)
    {
        __ChatterboxError("JSON string failed to decode");
        exit;
    }
    
    //Back up constant values
    var _constantValueArray = array_create(ds_list_size(_system.__constantsList));
    var _i = 0;
    repeat(ds_list_size(_system.__constantsList))
    {
        _constantValueArray[@ _i] = _system.__variablesMap[? _system.__constantsList[| _i]];
        ++_i;
    }
    
    ds_map_destroy(_system.__variablesMap);
    _system.__variablesMap = _json;
    
    //Reimport constants into new variables map
    var _i = 0;
    repeat(array_length(_constantValueArray))
    {
        _system.__variablesMap[? _system.__constantsList[| _i]] = _constantValueArray[@ _i];
        ++_i;
    }
}
