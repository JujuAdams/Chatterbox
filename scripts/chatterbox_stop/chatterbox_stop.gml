/// @param chatterbox

var _chatterbox = argument0;

var _text_list   = _chatterbox[| __CHATTERBOX.TEXTS   ];
var _button_list = _chatterbox[| __CHATTERBOX.BUTTONS ];

for(var _i = ds_list_size(_text_list  )-1; _i >= 0; _i--) scribble_destroy(_text_list[|   _i]);
for(var _i = ds_list_size(_button_list)-1; _i >= 0; _i--) scribble_destroy(_button_list[| _i]);
ds_list_clear(_text_list);
ds_list_clear(_button_list);

_chatterbox[| __CHATTERBOX.TITLE ] = undefined;