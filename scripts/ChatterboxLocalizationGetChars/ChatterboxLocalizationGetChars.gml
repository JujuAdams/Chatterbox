// Feather disable all

/// Returns an array of text characters (letters, numbers, symbols etc.) that are used in the
/// target localisation CSV. This is useful for building font ranges.
/// 
/// @param path  Path to the localisation file to use, relative to `CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY`
/// @param [returnCodepoints=false]  Whether to return numeric Unicode codepoint (`true`) or character strings (`false`)

function ChatterboxLocalizationGetChars(_path, _returnCodepoints)
{
    static _system = __ChatterboxSystem();
    
    if (_returnCodepoints)
    {
        var _method = method({
            __glyphMap: ds_map_create(),
        },
        function(_char)
        {
            __glyphMap[? ord(_char)] = true;
        });
    }
    else
    {
        var _method = method({
            __glyphMap: ds_map_create(),
        },
        function(_char)
        {
            __glyphMap[? _char] = true;
        });
    }
    
    var _localizationMap = ds_map_create();
    __ChatterboxLocalizationLoadIntoMap(_path, _localizationMap);
    
    var _valuesArray = ds_map_values_to_array(_localizationMap);
    var _i = 0;
    repeat(array_length(_valuesArray))
    {
        string_foreach(_valuesArray[_i], _method);
        ++_i;
    }
    
    ds_map_destroy(_localizationMap);
    
    var _map = method_get_self(_method).__glyphMap;
    var _glyphArray = ds_map_keys_to_array(_map);
    ds_map_destroy(_map);
    
    array_sort(_glyphArray, true);
    return _glyphArray;
}
