/// @param chatterbox

var _chatterbox = argument0;

var _chatterbox_left = _chatterbox[| __CHATTERBOX_HOST.LEFT ];
var _chatterbox_top  = _chatterbox[| __CHATTERBOX_HOST.TOP  ];

var _scribbles = _chatterbox[| __CHATTERBOX_HOST.SCRIBBLES ];
for(var _i = ds_list_size(_scribbles)-1; _i >= 0; _i--) scribble_draw(_scribbles[| _i], _chatterbox_left, _chatterbox_top);