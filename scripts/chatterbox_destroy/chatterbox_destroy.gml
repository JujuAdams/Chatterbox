/// @param chatterbox

var _chatterbox = argument0;

var _primary_scribble = _chatterbox[ __CHATTERBOX_HOST.PRIMARY_SCRIBBLE ];
if (_primary_scribble != undefined) scribble_destroy(_primary_scribble);

var _scribbles = _chatterbox[ __CHATTERBOX_HOST.SCRIBBLES ];
var _buttons   = _chatterbox[ __CHATTERBOX_HOST.BUTTONS   ];
var _instances = _chatterbox[ __CHATTERBOX_HOST.INSTANCES ];

for(var _i = array_length_1d(_scribbles)-1; _i >= 0; _i--) scribble_destroy(_scribbles[_i]);
for(var _i = array_length_1d(_buttons  )-1; _i >= 0; _i--) scribble_destroy(  _buttons[_i]);
for(var _i = array_length_1d(_instances)-1; _i >= 0; _i--) instance_destroy(_instances[_i]);