/// @param chatterbox

var _chatterbox = argument0;

var _text_list        = _chatterbox[| __CHATTERBOX.TEXTS        ];
var _button_list      = _chatterbox[| __CHATTERBOX.BUTTONS      ];
var _text_meta_list   = _chatterbox[| __CHATTERBOX.TEXTS_META   ];
var _button_meta_list = _chatterbox[| __CHATTERBOX.BUTTONS_META ];

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

for(var _i = ds_list_size(_button_list)-1; _i >= 0; _i--)
{
    var _button_array = _button_list[| _i];
    var _scribble = _button_array[ __CHATTERBOX_BUTTON.TEXT ];
    
    var _meta_array = _button_meta_list[| _i ];
    scribble_draw(_scribble,
                  _meta_array[ CHATTERBOX_PROPERTY.X      ], _meta_array[ CHATTERBOX_PROPERTY.Y      ],
                  _meta_array[ CHATTERBOX_PROPERTY.XSCALE ], _meta_array[ CHATTERBOX_PROPERTY.YSCALE ],
                  _meta_array[ CHATTERBOX_PROPERTY.ANGLE  ],
                  _meta_array[ CHATTERBOX_PROPERTY.BLEND  ], _meta_array[ CHATTERBOX_PROPERTY.ALPHA  ],
                  _meta_array[ CHATTERBOX_PROPERTY.PMA    ]);
}