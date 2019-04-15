/// @param chatterbox

var _chatterbox = argument0;

var _chatterbox_left = _chatterbox[| __CHATTERBOX.LEFT ];
var _chatterbox_top  = _chatterbox[| __CHATTERBOX.TOP  ];

var _scribble_list = _chatterbox[| __CHATTERBOX.TEXTS   ];
var _button_list   = _chatterbox[| __CHATTERBOX.BUTTONS ];
for(var _i = ds_list_size(_scribble_list)-1; _i >= 0; _i--) scribble_draw(_scribble_list[| _i], _chatterbox_left, _chatterbox_top);
for(var _i = ds_list_size(_button_list  )-1; _i >= 0; _i--)
{
    var _button_array = _button_list[| _i];
    scribble_draw(_button_array[ __CHATTERBOX_BUTTON.TEXT ], _chatterbox_left, _chatterbox_top);
}