/// @param chatterbox
/// @param [x]
/// @param [y]
/// @param [xscale]
/// @param [yscale]
/// @param [angle]
/// @param [colour]
/// @param [alpha]

var _chatterbox  = argument[0];
var _host_x      = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : 0;
var _host_y      = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : 0;
var _host_xscale = ((argument_count > 3) && (argument[3] != undefined))? argument[3] : 1;
var _host_yscale = ((argument_count > 4) && (argument[4] != undefined))? argument[4] : 1;
var _host_angle  = ((argument_count > 5) && (argument[5] != undefined))? argument[5] : 0;
var _host_colour = ((argument_count > 6) && (argument[6] != undefined))? argument[6] : c_white;
var _host_alpha  = ((argument_count > 7) && (argument[7] != undefined))? argument[7] : 1;

var _host_red   = colour_get_red(  _host_colour)/255;
var _host_green = colour_get_green(_host_colour)/255;
var _host_blue  = colour_get_blue( _host_colour)/255;

var _left = -_chatterbox[| __CHATTERBOX.ORIGIN_X ];
var _top  = -_chatterbox[| __CHATTERBOX.ORIGIN_Y ];


var _old_matrix = matrix_get(matrix_world);

if ((_host_xscale == 1) && (_host_yscale == 1) && (_host_angle == 0))
{
    var _matrix = matrix_build(_left + _host_x, _top + _host_y, 0,   0,0,0,   1,1,1);
}
else
{
    var _matrix = matrix_build(_left, _top, 0,   0,0,0,   1,1,1);
        _matrix = matrix_multiply(_matrix, matrix_build(_host_x,_host_y,0,   0,0,_host_angle,   _host_xscale,_host_yscale,1));
}

_matrix = matrix_multiply(_matrix, _old_matrix);
matrix_set(matrix_world, _matrix);



var _text_list        = _chatterbox[| __CHATTERBOX.TEXTS        ];
var _option_list      = _chatterbox[| __CHATTERBOX.OPTIONS      ];
var _text_meta_list   = _chatterbox[| __CHATTERBOX.TEXTS_META   ];
var _option_meta_list = _chatterbox[| __CHATTERBOX.OPTIONS_META ];

for(var _i = ds_list_size(_text_list)-1; _i >= 0; _i--)
{
    var _scribble = _text_list[| _i];
    
    var _meta_array = _text_meta_list[| _i ];
    
    var _colour = _meta_array[ CHATTERBOX_PROPERTY.BLEND ];
    if (_host_colour != c_white)
    {
        _colour = make_colour_rgb( colour_get_red(_colour)*_host_red, colour_get_green(_colour)*_host_green, colour_get_blue(_colour)*_host_blue);
    }
    
    scribble_draw(_scribble,
                  _meta_array[ CHATTERBOX_PROPERTY.X      ], _meta_array[ CHATTERBOX_PROPERTY.Y      ],
                  _meta_array[ CHATTERBOX_PROPERTY.XSCALE ], _meta_array[ CHATTERBOX_PROPERTY.YSCALE ],
                  _meta_array[ CHATTERBOX_PROPERTY.ANGLE  ],
                  _colour, _host_alpha*_meta_array[ CHATTERBOX_PROPERTY.ALPHA ],
                  _meta_array[ CHATTERBOX_PROPERTY.PMA    ]);
}

for(var _i = ds_list_size(_option_list)-1; _i >= 0; _i--)
{
    var _option_array = _option_list[| _i];
    var _scribble = _option_array[ __CHATTERBOX_OPTION.TEXT ];
    
    var _meta_array = _option_meta_list[| _i ];
    
    var _colour = _meta_array[ CHATTERBOX_PROPERTY.BLEND ];
    if (_host_colour != c_white)
    {
        _colour = make_colour_rgb( colour_get_red(_colour)*_host_red, colour_get_green(_colour)*_host_green, colour_get_blue(_colour)*_host_blue);
    }
    
    scribble_draw(_scribble,
                  _meta_array[ CHATTERBOX_PROPERTY.X      ], _meta_array[ CHATTERBOX_PROPERTY.Y      ],
                  _meta_array[ CHATTERBOX_PROPERTY.XSCALE ], _meta_array[ CHATTERBOX_PROPERTY.YSCALE ],
                  _meta_array[ CHATTERBOX_PROPERTY.ANGLE  ],
                  _colour, _host_alpha*_meta_array[ CHATTERBOX_PROPERTY.ALPHA ],
                  _meta_array[ CHATTERBOX_PROPERTY.PMA    ]);
}



matrix_set(matrix_world, _old_matrix);