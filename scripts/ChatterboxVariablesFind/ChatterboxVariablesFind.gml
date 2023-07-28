// Feather disable all
/// Returns an array of variable names that match the given substring and search mode
/// 
/// Mode should be 0, 1, or 2:
/// mode = 0: Substring must be present anywhere in the variable name
/// mode = 1: Substring must prefix the variable name
/// mode = 2: Substring must suffix the variable name
/// 
/// @param substring
/// @param mode
/// @param caseSensitive

function ChatterboxVariablesFind(_substring, _mode, _case_sensitive)
{
    var _result = [];
    
    if (!_case_sensitive) _substring = string_lower(_substring);
    var _substring_length = string_length(_substring);
    
    var _name = ds_map_find_first(global.__chatterboxVariablesMap);
    repeat(ds_map_size(global.__chatterboxVariablesMap))
    {
        var _string = _case_sensitive? _name : string_lower(_name);
        
        switch(_mode)
        {
            case 0: //Substring should be present anywhere in the variable name
                if (string_pos(_substring, _string) > 0)
                {
                    array_push(_result, _name);
                }
            break;
            
            case 1: //Substring should must prefix the variable name
                if (string_copy(_string, 1, _substring_length) == _substring)
                {
                    array_push(_result, _name);
                }
            break;
            
            case 2: //Substring should must suffix the variable name
                if (string_copy(_string, 1 + string_length(_string) - _substring_length, _substring_length) == _substring)
                {
                    array_push(_result, _name);
                }
            break;
        }
        
        _name = ds_map_find_next(global.__chatterboxVariablesMap, _name);
    }
    
    return _result;
}
