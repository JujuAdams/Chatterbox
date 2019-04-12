/// @param chatterbox

var _chatterbox = argument0;

var _scribbles = _chatterbox[| __CHATTERBOX.SCRIBBLES ];
var _buttons   = _chatterbox[| __CHATTERBOX.BUTTONS   ];

for(var _i = ds_list_size(_scribbles)-1; _i >= 0; _i--) scribble_step(_scribbles[| _i]);
for(var _i = ds_list_size(_buttons  )-1; _i >= 0; _i--) scribble_step(  _buttons[| _i]);