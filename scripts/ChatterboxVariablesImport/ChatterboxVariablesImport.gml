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
    var _variablesMap  = _system.__variablesMap;
    var _constantsList = _system.__constantsList;
    
    var _constantValueArray = array_create(ds_list_size(_constantsList));
    var _i = 0;
    repeat(ds_list_size(_constantsList))
    {
        var _variableName = _constantsList[| _i];
        
        if (ds_map_exists(_variablesMap, _variableName))
        {
            _constantValueArray[@ _i] = _variablesMap[? _variableName];
        }
        else
        {
            _constantValueArray[@ _i] = pointer_null; //Hack!
        }
        
        ++_i;
    }
    
    //Load in the variables wholesale
    ds_map_destroy(_variablesMap);
    _variablesMap = _json;
    _system.__variablesMap = _variablesMap;
    
    //Reimport constants into new variables map
    var _i = 0;
    repeat(array_length(_constantValueArray))
    {
        var _value = _constantValueArray[_i];
        if (not is_ptr(_value))
        {
            _variablesMap[? _constantsList[| _i]] = _constantValueArray[@ _i];
        }
        
        ++_i;
    }
}
