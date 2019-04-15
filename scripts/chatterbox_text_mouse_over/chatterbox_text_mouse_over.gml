/// @param chatterbox
/// @param mouseX
/// @param mouseY

var _chatterbox = argument0;
var _mouse_x    = argument1;
var _mouse_y    = argument2;

var _list      = _chatterbox[| __CHATTERBOX.BUTTONS      ];
var _meta_list = _chatterbox[| __CHATTERBOX.BUTTONS_META ];

var _count = ds_list_size(_list);
for(var _i = 0; _i < _count; _i++)
{
    var _array = _list[| _i ];
    var _scribble = _array[ __CHATTERBOX_BUTTON.TEXT ];
    
    var _meta_array = _meta_list[| _i ];
    var _box = scribble_get_box(_scribble, 
                                _meta_array[ CHATTERBOX_PROPERTY.X      ], _meta_array[ CHATTERBOX_PROPERTY.Y      ],
                                -1, -1, -1, -1,
                                _meta_array[ CHATTERBOX_PROPERTY.XSCALE ], _meta_array[ CHATTERBOX_PROPERTY.YSCALE ],
                                _meta_array[ CHATTERBOX_PROPERTY.ANGLE  ]);
    
    if (point_in_triangle(_mouse_x, _mouse_y,
                          _box[SCRIBBLE_BOX.X0], _box[SCRIBBLE_BOX.Y0],
                          _box[SCRIBBLE_BOX.X1], _box[SCRIBBLE_BOX.Y1],
                          _box[SCRIBBLE_BOX.X2], _box[SCRIBBLE_BOX.Y2]))
    {
        return _i;
    }
    
    if (point_in_triangle(_mouse_x, _mouse_y,
                          _box[SCRIBBLE_BOX.X1], _box[SCRIBBLE_BOX.Y1],
                          _box[SCRIBBLE_BOX.X2], _box[SCRIBBLE_BOX.Y2],
                          _box[SCRIBBLE_BOX.X3], _box[SCRIBBLE_BOX.Y3]))
    {
        return _i;
    }
}

return undefined;