/// @param chatterbox
/// @param buttons

var _chatterbox = argument0;
var _buttons    = argument1;

var _list = _chatterbox[| _buttons? __CHATTERBOX.BUTTONS : __CHATTERBOX.TEXTS ];
return ds_list_size(_list);