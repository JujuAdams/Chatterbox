// Feather disable all
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
    
    //Back up constant values
    var _constantValueArray = array_create(ds_list_size(global.__chatterboxConstantsList));
    var _i = 0;
    repeat(ds_list_size(global.__chatterboxConstantsList))
    {
        _constantValueArray[@ _i] = global.__chatterboxVariablesMap[? global.__chatterboxConstantsList[| _i]];
        ++_i;
    }
    
    ds_map_destroy(global.__chatterboxVariablesMap);
    global.__chatterboxVariablesMap = _json;
    
    //Reimport constants into new variables map
    var _i = 0;
    repeat(array_length(_constantValueArray))
    {
        global.__chatterboxVariablesMap[? global.__chatterboxConstantsList[| _i]] = _constantValueArray[@ _i];
        ++_i;
    }
}
