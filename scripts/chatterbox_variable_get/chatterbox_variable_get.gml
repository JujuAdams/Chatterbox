/// @param variableName
/// @param [defaultValue]

var _variable      = argument[0];
var _default_value = (argument_count > 1)? argument[1] : CHATTERBOX_DEFAULT_VARIABLE_VALUE;

if (ds_map_exists(global.__chatterbox_variables, _variable)) return global.__chatterbox_variables[? _variable ];
return _default_value;