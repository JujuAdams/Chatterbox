/// @param chatterbox
/// @param variableName
/// @param value

var _chatterbox = argument0;
var _variable   = argument1;
var _value      = argument2;

var _variables_map = _chatterbox[| __CHATTERBOX.VARIABLES ];
_variables_map[? _variable ] = _value;