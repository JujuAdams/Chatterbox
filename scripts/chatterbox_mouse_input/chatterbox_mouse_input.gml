/// @param chatterbox
/// @param mouseX
/// @param mouseY
/// @param select
/// @param overwrite

var _chatterbox = argument0;
var _mouse_x    = argument1;
var _mouse_y    = argument2;
var _select     = argument3;
var _overwrite  = argument4;

var _highlighted_index = _chatterbox[| __CHATTERBOX.HIGHLIGHTED ];
var _option_list       = _chatterbox[| __CHATTERBOX.OPTION_LIST ];

var _count = ds_list_size(_option_list);
for(var _i = 0; _i < _count; _i++)
{
    var _array = _option_list[| _i ];
    var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
    if (_scribble == undefined) continue;
    
    var _box = scribble_get_box(_scribble, 
                                _array[ CHATTERBOX_PROPERTY.X      ], _array[ CHATTERBOX_PROPERTY.Y      ],
                                -1, -1, -1, -1,
                                _array[ CHATTERBOX_PROPERTY.XSCALE ], _array[ CHATTERBOX_PROPERTY.YSCALE ],
                                _array[ CHATTERBOX_PROPERTY.ANGLE  ]);
        
    if (point_in_triangle(_mouse_x, _mouse_y,
                            _box[SCRIBBLE_BOX.X0], _box[SCRIBBLE_BOX.Y0],
                            _box[SCRIBBLE_BOX.X1], _box[SCRIBBLE_BOX.Y1],
                            _box[SCRIBBLE_BOX.X2], _box[SCRIBBLE_BOX.Y2]))
    {
        _highlighted_index = _i;
        break;
    }
    else if (point_in_triangle(_mouse_x, _mouse_y,
                                _box[SCRIBBLE_BOX.X1], _box[SCRIBBLE_BOX.Y1],
                                _box[SCRIBBLE_BOX.X2], _box[SCRIBBLE_BOX.Y2],
                                _box[SCRIBBLE_BOX.X3], _box[SCRIBBLE_BOX.Y3]))
    {
        _highlighted_index = _i;
        break;
    }
}

if (_overwrite && (_i >= _count)) _highlighted_index = undefined;
_chatterbox[| __CHATTERBOX.HIGHLIGHTED ] = _highlighted_index;
if ((_i < _count) && _select) _chatterbox[| __CHATTERBOX.SELECTED ] = true;

return (_i < _count);