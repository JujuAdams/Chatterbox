/// @param chatterbox

var _chatterbox = argument0;

var _scribble_list = _chatterbox[| __CHATTERBOX.SCRIBBLES ];
var _button_list   = _chatterbox[| __CHATTERBOX.BUTTONS   ];

for(var _i = ds_list_size(_scribble_list)-1; _i >= 0; _i--) scribble_destroy(_scribble_list[| _i]);
for(var _i = ds_list_size(_button_list  )-1; _i >= 0; _i--) scribble_destroy(  _button_list[| _i]);
ds_list_clear(_scribble_list);
ds_list_clear(_button_list);

_chatterbox[| __CHATTERBOX.TITLE ] = undefined;