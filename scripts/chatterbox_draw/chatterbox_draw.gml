/// @param chatterbox
/// @param [x]
/// @param [y]

var _chatterbox = argument[0];
var _host_x     = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : 0;
var _host_y     = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : 0;

var _text_list        = _chatterbox[| __CHATTERBOX.TEXTS        ];
var _option_list      = _chatterbox[| __CHATTERBOX.OPTIONS      ];
var _text_meta_list   = _chatterbox[| __CHATTERBOX.TEXTS_META   ];
var _option_meta_list = _chatterbox[| __CHATTERBOX.OPTIONS_META ];

for(var _i = ds_list_size(_text_list)-1; _i >= 0; _i--)
{
    var _scribble = _text_list[| _i];
    
    var _meta_array = _text_meta_list[| _i ];
    var _x = _meta_array[ CHATTERBOX_PROPERTY.X ] + _host_x;
    var _y = _meta_array[ CHATTERBOX_PROPERTY.Y ] + _host_y;
    
    scribble_draw(_scribble,
                  _x, _y,
                  _meta_array[ CHATTERBOX_PROPERTY.XSCALE ], _meta_array[ CHATTERBOX_PROPERTY.YSCALE ],
                  _meta_array[ CHATTERBOX_PROPERTY.ANGLE  ],
                  _meta_array[ CHATTERBOX_PROPERTY.BLEND  ], _meta_array[ CHATTERBOX_PROPERTY.ALPHA  ],
                  _meta_array[ CHATTERBOX_PROPERTY.PMA    ]);
}

for(var _i = ds_list_size(_option_list)-1; _i >= 0; _i--)
{
    var _option_array = _option_list[| _i];
    var _scribble = _option_array[ __CHATTERBOX_OPTION.TEXT ];
    
    var _meta_array = _option_meta_list[| _i ];
    var _x = _meta_array[ CHATTERBOX_PROPERTY.X ] + _host_x;
    var _y = _meta_array[ CHATTERBOX_PROPERTY.Y ] + _host_y;
    
    scribble_draw(_scribble,
                  _x, _y,
                  _meta_array[ CHATTERBOX_PROPERTY.XSCALE ], _meta_array[ CHATTERBOX_PROPERTY.YSCALE ],
                  _meta_array[ CHATTERBOX_PROPERTY.ANGLE  ],
                  _meta_array[ CHATTERBOX_PROPERTY.BLEND  ], _meta_array[ CHATTERBOX_PROPERTY.ALPHA  ],
                  _meta_array[ CHATTERBOX_PROPERTY.PMA    ]);
}