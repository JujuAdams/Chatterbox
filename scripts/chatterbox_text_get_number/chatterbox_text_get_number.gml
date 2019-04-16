/// @param chatterbox
/// @param options

var _chatterbox = argument0;
var _options    = argument1;

var _list = _chatterbox[| _options? __CHATTERBOX.OPTIONS_META : __CHATTERBOX.TEXTS_META ];
return ds_list_size(_list);