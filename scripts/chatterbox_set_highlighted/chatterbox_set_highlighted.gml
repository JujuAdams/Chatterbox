/// @param chatterbox
/// @param buttonIndex
/// @param [relative]

var _chatterbox = argument[0];
var _index      = argument[1];
var _relative   = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : false;

if (!is_real(_index)) return false;

var _button_list = _chatterbox[| __CHATTERBOX.BUTTONS ];

if (_relative) _index = _chatterbox[| __CHATTERBOX.HIGHLIGHTED ] + _index;
_index = clamp(_index, 0, ds_list_size(_button_list)-1);

_chatterbox[| __CHATTERBOX.HIGHLIGHTED ] = _index;

return true;