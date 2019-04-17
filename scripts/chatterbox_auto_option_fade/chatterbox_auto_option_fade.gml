/// @param chatterbox
/// @param inTextThreshold
/// @param inOptionThreshold
/// @param outTextThreshold
/// @param outOptionThreshold

var _chatterbox           = argument0;
var _in_threshold_text    = argument1;
var _in_threshold_option  = argument2;
var _out_threshold_text   = argument3;
var _out_threshold_option = argument4;

var _text_list       = _chatterbox[| __CHATTERBOX.TEXT_LIST       ];
var _option_list     = _chatterbox[| __CHATTERBOX.OPTION_LIST     ];
var _old_text_list   = _chatterbox[| __CHATTERBOX.OLD_TEXT_LIST   ];
var _old_option_list = _chatterbox[| __CHATTERBOX.OLD_OPTION_LIST ];

var _text_size       = ds_list_size(_text_list);
var _option_size     = ds_list_size(_option_list);
var _old_text_size   = ds_list_size(_old_text_list);
var _old_option_size = ds_list_size(_old_option_list);

//Fade in
var _previous_state = 1;
for(var _i = _text_size-1; _i >= 0; _i--)
{
    var _array = _text_list[| _i];
    var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
    if (_scribble == undefined) continue;
    
    var _state = scribble_typewriter_get_state(_scribble);
    if (_state == undefined)
    {
        scribble_typewriter_in(_scribble,
                               _chatterbox[| __CHATTERBOX.TEXT_FADE_IN_METHOD     ],
                               _chatterbox[| __CHATTERBOX.TEXT_FADE_IN_SPEED      ],
                               _chatterbox[| __CHATTERBOX.TEXT_FADE_IN_SMOOTHNESS ]);
        scribble_step(_scribble);
    }
    
    _previous_state = scribble_typewriter_get_state(_scribble);
}


for(var _i = 0; _i < _option_size; _i++)
{
    var _array = _option_list[| _i ];
    var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
    if (_scribble == undefined) continue;
    
    var _state = scribble_typewriter_get_state(_scribble);
    if ((_state == undefined) || (_state == 0))
    {
        if (_previous_state >= ((_i == 0)? _in_threshold_text: _in_threshold_option))
        {
            scribble_typewriter_in(_scribble,
                                   _chatterbox[| __CHATTERBOX.OPTION_FADE_IN_METHOD     ],
                                   _chatterbox[| __CHATTERBOX.OPTION_FADE_IN_SPEED      ],
                                   _chatterbox[| __CHATTERBOX.OPTION_FADE_IN_SMOOTHNESS ]);
            scribble_step(_scribble);
        }
        else
        {
            scribble_typewriter_in(_scribble,
                                   _chatterbox[| __CHATTERBOX.OPTION_FADE_IN_METHOD     ],
                                   0,
                                   _chatterbox[| __CHATTERBOX.OPTION_FADE_IN_SMOOTHNESS ]);
        }
    }
    
    if (_in_threshold_option > 0) _previous_state = scribble_typewriter_get_state(_scribble);
}

//Fade out children
var _previous_state = 2;
for(var _i = _old_text_size-1; _i >= 0; _i--)
{
    var _array = _old_text_list[| _i];
    var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
    
    var _state = scribble_typewriter_get_state(_scribble);
    if ((_state != undefined) && (_state == 1))
    {
        scribble_typewriter_out(_scribble,
                                _chatterbox[| __CHATTERBOX.TEXT_FADE_OUT_METHOD     ],
                                _chatterbox[| __CHATTERBOX.TEXT_FADE_OUT_SPEED      ],
                                _chatterbox[| __CHATTERBOX.TEXT_FADE_OUT_SMOOTHNESS ]);
        scribble_step(_scribble);
    }
    
    _previous_state = _state;
}

for(var _i = 0; _i < _old_option_size; _i++)
{
    var _array = _old_option_list[| _i ];
    var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
    if (_scribble == undefined) continue;
    
    var _state = scribble_typewriter_get_state(_scribble);
    if ((_state != undefined) && (_state == 1))
    {
        if (_previous_state >= ((_i == 0)? _out_threshold_text : _out_threshold_option))
        {
            scribble_typewriter_out(_scribble,
                                    _chatterbox[| __CHATTERBOX.OPTION_FADE_OUT_METHOD     ],
                                    _chatterbox[| __CHATTERBOX.OPTION_FADE_OUT_SPEED      ],
                                    _chatterbox[| __CHATTERBOX.OPTION_FADE_OUT_SMOOTHNESS ]);
            scribble_step(_scribble);
        }
    }
    
    if (_out_threshold_option > 0) _previous_state = _state;
}