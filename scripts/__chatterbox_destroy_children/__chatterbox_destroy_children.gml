/// @param chatterbox

var _chatterbox = argument0;

var _list = _chatterbox[| __CHATTERBOX.TEXTS_META ];
for(var _i = ds_list_size(_list)-1; _i >= 0; _i--)
{
    var _array = _list[| _i];
    scribble_destroy(_array[ CHATTERBOX_PROPERTY.SCRIBBLE ]);
}
ds_list_clear(_list);

var _list = _chatterbox[| __CHATTERBOX.OPTIONS_META ];
for(var _i = ds_list_size(_list)-1; _i >= 0; _i--)
{
    var _array = _list[| _i];
    scribble_destroy(_array[ CHATTERBOX_PROPERTY.SCRIBBLE ]);
}
ds_list_clear(_list);