/// @param chatterbox
/// @param options

var _chatterbox = argument0;
var _options    = argument1;

var _list = _chatterbox[| _options? __CHATTERBOX.OPTION_LIST : __CHATTERBOX.TEXT_LIST ];
return ds_list_size(_list);