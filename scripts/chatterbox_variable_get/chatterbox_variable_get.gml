/// @param chatterbox
/// @param variableName
/// @param [defaultValue]

var _chatterbox    = argument[0];
var _variable      = argument[1];
var _default_value = (argument_count > 2)? argument[2] : CHATTERBOX_DEFAULT_VARIABLE_VALUE;

var _variables_map = __CHATTERBOX_VARIABLE_MAP;
if (ds_map_exists(_variables_map, _variable)) return _variables_map[? _variable ];
return _default_value;