/// @param chatterbox

var _chatterbox = argument0;

var _text_list   = _chatterbox[| __CHATTERBOX.TEXTS   ];
var _option_list = _chatterbox[| __CHATTERBOX.OPTIONS ];

for(var _i = ds_list_size(_text_list  )-1; _i >= 0; _i--) scribble_destroy(_text_list[|   _i]);
for(var _i = ds_list_size(_option_list)-1; _i >= 0; _i--)
{
    var _option_array = _option_list[| _i];
    scribble_destroy(_option_array[ __CHATTERBOX_OPTION.TEXT ]);
}
ds_list_clear(_text_list);
ds_list_clear(_option_list);