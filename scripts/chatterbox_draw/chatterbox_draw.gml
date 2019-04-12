/// @param chatterbox

var _chatterbox = argument0;

var _chatterbox_left   = _chatterbox[ __CHATTERBOX_HOST.LEFT   ];
var _chatterbox_top    = _chatterbox[ __CHATTERBOX_HOST.TOP    ];
var _chatterbox_right  = _chatterbox[ __CHATTERBOX_HOST.RIGHT  ];
var _chatterbox_bottom = _chatterbox[ __CHATTERBOX_HOST.BOTTOM ];

var _primary_scribble = _chatterbox[ __CHATTERBOX_HOST.PRIMARY_SCRIBBLE ];
scribble_draw(_primary_scribble, _chatterbox_left, _chatterbox_top);