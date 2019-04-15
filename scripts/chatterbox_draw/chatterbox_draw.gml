/// @param chatterbox

var _chatterbox = argument0;

var _text_list        = _chatterbox[| __CHATTERBOX.TEXTS        ];
var _option_list      = _chatterbox[| __CHATTERBOX.OPTIONS      ];
var _text_meta_list   = _chatterbox[| __CHATTERBOX.TEXTS_META   ];
var _option_meta_list = _chatterbox[| __CHATTERBOX.OPTIONS_META ];

for(var _i = ds_list_size(_text_list)-1; _i >= 0; _i--)
{
    var _scribble = _text_list[| _i];
    
    var _meta_array = _text_meta_list[| _i ];
    scribble_draw(_scribble,
                  _meta_array[ CHATTERBOX_PROPERTY.X      ], _meta_array[ CHATTERBOX_PROPERTY.Y      ],
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
    scribble_draw(_scribble,
                  _meta_array[ CHATTERBOX_PROPERTY.X      ], _meta_array[ CHATTERBOX_PROPERTY.Y      ],
                  _meta_array[ CHATTERBOX_PROPERTY.XSCALE ], _meta_array[ CHATTERBOX_PROPERTY.YSCALE ],
                  _meta_array[ CHATTERBOX_PROPERTY.ANGLE  ],
                  _meta_array[ CHATTERBOX_PROPERTY.BLEND  ], _meta_array[ CHATTERBOX_PROPERTY.ALPHA  ],
                  _meta_array[ CHATTERBOX_PROPERTY.PMA    ]);
}