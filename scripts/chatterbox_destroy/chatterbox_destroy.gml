/// @param chatterbox

var _chatterbox = argument0;

var _scribbles = _chatterbox[| __CHATTERBOX_HOST.SCRIBBLES ];
var _buttons   = _chatterbox[| __CHATTERBOX_HOST.BUTTONS   ];
var _instances = _chatterbox[| __CHATTERBOX_HOST.INSTANCES ];

for(var _i = ds_list_size(_scribbles)-1; _i >= 0; _i--) scribble_destroy(_scribbles[| _i]);
for(var _i = ds_list_size(_buttons  )-1; _i >= 0; _i--) scribble_destroy(  _buttons[| _i]);
for(var _i = ds_list_size(_instances)-1; _i >= 0; _i--) instance_destroy(_instances[| _i]);

ds_list_destroy(_chatterbox);