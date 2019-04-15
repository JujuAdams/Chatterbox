/// @param json            The Chatterbox data structure to process
/// @param [selectOption] 
/// @param [stepSize]      The step size e.g. a delta time coefficient. Defaults to CHATTERBOX_DEFAULT_STEP_SIZE

var _chatterbox = argument[0];
var _select     = ((argument_count > 1) && (argument_count[1] != undefined))? argument[1] : undefined;
var _step_size  = ((argument_count > 2) && (argument_count[2] != undefined))? argument[2] : CHATTERBOX_DEFAULT_STEP_SIZE;



var _node_title        = _chatterbox[| __CHATTERBOX.TITLE        ];
var _filename          = _chatterbox[| __CHATTERBOX.FILENAME     ];
var _text_list         = _chatterbox[| __CHATTERBOX.TEXTS        ];
var _button_list       = _chatterbox[| __CHATTERBOX.BUTTONS      ];
var _text_meta_list    = _chatterbox[| __CHATTERBOX.TEXTS_META   ];
var _button_meta_list  = _chatterbox[| __CHATTERBOX.BUTTONS_META ];
var _executed_map      = _chatterbox[| __CHATTERBOX.EXECUTED_MAP ];
var _highlighted_index = _chatterbox[| __CHATTERBOX.HIGHLIGHTED  ];

if (_node_title == undefined)
{
    //If the node title is <undefined> then this chatterbox has been stopped
    exit;
}



#region Automatic option selection behaviours

if (CHATTERBOX_AUTO_KEYBOARD)
{
    if (CHATTERBOX_AUTO_KEYBOARD_UP)   _highlighted_index--;
    if (CHATTERBOX_AUTO_KEYBOARD_DOWN) _highlighted_index++;
    _select = CHATTERBOX_AUTO_KEYBOARD_SELECT;
    
    _highlighted_index = clamp(_highlighted_index, 0, ds_list_size(_button_list)-1);
    _chatterbox[| __CHATTERBOX.HIGHLIGHTED ] = _highlighted_index;
}

if (CHATTERBOX_AUTO_MOUSE)
{
    var _count = ds_list_size(_button_list);
    for(var _i = 0; _i < _count; _i++)
    {
        var _array = _button_list[| _i ];
        var _scribble = _array[ __CHATTERBOX_BUTTON.TEXT ];
        
        var _meta_array = _button_meta_list[| _i ];
        var _box = scribble_get_box(_scribble, 
                                    _meta_array[ CHATTERBOX_PROPERTY.X      ], _meta_array[ CHATTERBOX_PROPERTY.Y      ],
                                    -1, -1, -1, -1,
                                    _meta_array[ CHATTERBOX_PROPERTY.XSCALE ], _meta_array[ CHATTERBOX_PROPERTY.YSCALE ],
                                    _meta_array[ CHATTERBOX_PROPERTY.ANGLE  ]);
        
        var _mouse_x = CHATTERBOX_AUTO_MOUSE_X;
        var _mouse_y = CHATTERBOX_AUTO_MOUSE_Y;
        
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
    
    if (!CHATTERBOX_AUTO_KEYBOARD && (_i >= _count)) _highlighted_index = undefined;
    _chatterbox[| __CHATTERBOX.HIGHLIGHTED ] = _highlighted_index;
    _select = ((_i < _count) && CHATTERBOX_AUTO_MOUSE_SELECT);
}

#endregion



//Perform a step for all nested Scribble data structures
for(var _i = ds_list_size(_text_list  )-1; _i >= 0; _i--) scribble_step(_text_list[|   _i], _step_size);
for(var _i = ds_list_size(_button_list)-1; _i >= 0; _i--)
{
    var _button_array = _button_list[| _i];
    scribble_step(_button_array[ __CHATTERBOX_BUTTON.TEXT ], _step_size);
}



var _title_map = global.__chatterbox_data[? _filename ];
var _instruction_list = _title_map[? _node_title ];

var _indent = 0;

var _evaluate = false;
if (!_chatterbox[| __CHATTERBOX.INITIALISED])
{
    #region Handle chatterboxes that haven't been initialised yet
    _chatterbox[| __CHATTERBOX.INITIALISED ] = true;
    _chatterbox[| __CHATTERBOX.HIGHLIGHTED ] = 0;
    
    //If this chatterbox hasn't been initialised skip straight to evaluation
    _evaluate = true;
    
    var _instruction       = _chatterbox[| __CHATTERBOX.INSTRUCTION ];
    var _instruction_array = _instruction_list[| _instruction];
        _indent            = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
        
    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set instruction = " + string(_instruction));
    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
    
    #endregion
}
else
{
    #region Advance to the next instruction if the player has selected an option
    
    if (_select && (_highlighted_index != undefined))
    {
        _chatterbox[| __CHATTERBOX.HIGHLIGHTED ] = 0;
        
        var _button_array = _button_list[| _highlighted_index ];
        var _instruction = _button_array[ __CHATTERBOX_BUTTON.INSTRUCTION ];
        
        var _button_array   = _instruction_list[| _instruction];
        var _button_type    = _button_array[ __CHATTERBOX_INSTRUCTION.TYPE    ];
        var _button_indent  = _button_array[ __CHATTERBOX_INSTRUCTION.INDENT  ];
        var _button_content = _button_array[ __CHATTERBOX_INSTRUCTION.CONTENT ];
        
        show_debug_message("Chatterbox: Selected option " + string(_highlighted_index) + ", \"" + string(_button_content[0]) + "\"");
        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set instruction = " + string(_instruction));
        
        switch(_button_type)
        {
            case __CHATTERBOX_VM_TEXT:
                //Advance to the next instruction
                _instruction++;
                //Use the ident value of the text itself
                _indent = _button_indent;
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
            break;
            
            case __CHATTERBOX_VM_SHORTCUT:
                //Advance to the next instruction
                _instruction++;
                //Use the ident value of the next instruction
                var _instruction_array = _instruction_list[| _instruction ];
                    _indent            = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
            break;
            
            case __CHATTERBOX_VM_OPTION:
                //Jump out to another node
                var _content = _button_array[ __CHATTERBOX_INSTRUCTION.CONTENT ];
                chatterbox_start(_chatterbox, _content[1]);
                exit;
            break;
        }
        
        _evaluate = true;
    }
    
    #endregion
}

if (_evaluate)
{
    __chatterbox_destroy_children(_chatterbox);
    
    #region Evaluate Yarn virtual machine
    
    var _if_state = true;
    var _found_text = false;
    var _permit_greater_indent = false;
    
    var _break = false;
    repeat(9999)
    {
        var _continue = false;
        
        var _instruction_array   = _instruction_list[| _instruction ];
        var _instruction_type    = _instruction_array[ __CHATTERBOX_INSTRUCTION.TYPE    ];
        var _instruction_indent  = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT  ];
        var _instruction_content = _instruction_array[ __CHATTERBOX_INSTRUCTION.CONTENT ];
        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   " + _instruction_type + ":   " + string(_instruction_indent) + ":   " + string(_instruction_content));
        
        #region Identation behaviours
        
        if (_instruction_indent < _indent)
        {
            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction indent " + string(_instruction_indent) + " < indent " + string(_indent));
            if (!_found_text)
            {
                _indent = _instruction_indent;
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set indent = " + string(_indent));
            }
            else
            {
                _break = true;
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Break");
            }
        }
        else if (_instruction_indent > _indent)
        {
            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction indent " + string(_instruction_indent) + " > indent " + string(_indent));
            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       _permit_greater_indent=" + string(_permit_greater_indent));
            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       indent difference=" + string(_instruction_indent - _indent));
            if (_permit_greater_indent && ((_instruction_indent - _indent) <= CHATTERBOX_TAB_INDENT_SIZE))
            {
                _indent = _instruction_indent;
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":         Set indent = " + string(_indent));
            }
            else
            {
                _continue = true;
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":         Continue");
            }
        }
        
        _permit_greater_indent = false;
        
        #endregion
        
        #region Handle branches
        
        if (!_break && !_continue)
        {
            switch(_instruction_type)
            {
                case __CHATTERBOX_VM_IF:
                case __CHATTERBOX_VM_ELSEIF:
                    //Only evaluate the if-statement if we passed the previous check
                    if (_instruction_type == __CHATTERBOX_VM_IF)
                    {
                        if (!_if_state)
                        {
                            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _if_state == " + string(_if_state));
                            _continue = true;
                            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Continue");
                            break;
                        }
                    }
                    
                    //Only evaluate the elseif-statement if we failed the previous check
                    if (_instruction_type == __CHATTERBOX_VM_ELSEIF)
                    {
                        if (_if_state)
                        {
                            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _if_state == " + string(_if_state));
                            _if_state = false;
                            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set _if_state = " + string(_if_state));
                            _continue = true;
                            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Continue");
                            break;
                        }
                    }
                    
                    var _result = __chatterbox_evaluate(_chatterbox, _instruction_content);
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   Evaluator returned \"" + string(_result) + "\" (" + typeof(_result) + ")");
                    
                    if (!is_bool(_result) && !is_real(_result))
                    {
                        show_debug_message("Chatterbox: WARNING! Expression evaluator returned an invalid datatype (" + typeof(_result) + ")");
                        var _if_state = false;
                    }
                    else
                    {
                        var _if_state = _result;
                    }
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   Set _if_state = " + string(_if_state));
                    
                    if (_if_state)
                    {
                        _permit_greater_indent = true;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   Set _permit_greater_indent = " + string(_permit_greater_indent));
                    }
                break;
                
                case __CHATTERBOX_VM_ELSE:
                    _if_state = !_if_state;
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Invert _if_state = " + string(_if_state));
                    
                    if (_if_state)
                    {
                        _permit_greater_indent = true;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _permit_greater_indent = " + string(_permit_greater_indent));
                    }
                break;
                
                case __CHATTERBOX_VM_IF_END:
                    _if_state = true;
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _if_state = " + string(_if_state));
                break;
            }
            
        }
        
        if (!_break && !_continue)
        {
            //If we're inside a branch that has been evaluated as <false> then keep skipping until we close the branch
            if (!_if_state)
            {
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   _if_state == " + string(_if_state));
                _continue = true;
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Continue");
            }
        }
        
        #endregion
        
        if (!_break && !_continue)
        {
            #region Handle instructions
            
            var _new_button      = false;
            var _new_button_text = "";
            switch(_instruction_type)
            {
                case __CHATTERBOX_VM_TEXT:
                    if (_found_text)
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _found_text == " + string(_found_text));
                        _break = true;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Break");
                        break;
                    }
                    
                    _found_text = true;
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _found_text = " + string(_found_text));
                    
                    var _text = scribble_create(_instruction_content[0]);
                    ds_list_insert(_text_list, 0, _text);
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Created text");
                    
                    var _text_instruction = _instruction; //Record the instruction position of the text
                break;
                
                case __CHATTERBOX_VM_SHORTCUT:
                case __CHATTERBOX_VM_OPTION:
                    if (!_found_text) break;
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _found_text == " + string(_found_text));
                    _new_button = true;
                    _new_button_text = _instruction_content[0];
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       New button \"" + string(_new_button_text) + "\"");
                break;
                
                case __CHATTERBOX_VM_SET:
                    if (!ds_map_exists(_executed_map, _instruction))
                    {
                        _executed_map[? _instruction ] = true;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     now executing");
                        
                        __chatterbox_evaluate(_chatterbox, _instruction_content);
                    }
                    else
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     not executed before, ignoring");
                    }
                break;
                
                case __CHATTERBOX_VM_CUSTOM_ACTION:
                    if (!ds_map_exists(_executed_map, _instruction))
                    {
                        _executed_map[? _instruction ] = true;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     now executing");
                        
                        var _argument_array = array_create(array_length_1d(_instruction_content)-1);
                        array_copy(_argument_array, 0, _instruction_content, 1, array_length_1d(_instruction_content)-1);
                        
                        var _i = 0;
                        repeat(array_length_1d(_argument_array))
                        {
                            _argument_array[_i] = __chatterbox_resolve_value(_chatterbox, _argument_array[_i]);
                            _i++;
                        }
                        
                        script_execute(global.__chatterbox_actions[? _instruction_content[0] ], _argument_array);
                    }
                    else
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     not executed before, ignoring");
                    }
                break;
                
                case __CHATTERBOX_VM_STOP:
                    if (!_found_text)
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _found_text == " + string(_found_text));
                        chatterbox_stop(_chatterbox);
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Stop");
                        exit;
                    }
                    else
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Break");
                        _break = true;
                        break;
                    }
                break;
            }
            
            #endregion
        
            #region Create a new button from SHORTCUT and OPTION instructions
            
            if (_new_button)
            {
                _new_button = false;
                
                var _button_array = array_create(__CHATTERBOX_BUTTON.__SIZE);
                _button_array[ __CHATTERBOX_BUTTON.TEXT        ] = scribble_create(_new_button_text);
                _button_array[ __CHATTERBOX_BUTTON.INSTRUCTION ] = _instruction;
                ds_list_add(_button_list, _button_array);
            }
            #endregion
        }
        
        if (_break) break;
        
        _instruction++;
    }
    
    #region Create a new button from a TEXT instruction if no option or shortcut was found
    
    if (ds_list_size(_button_list) <= 0)
    {
        var _button_array = array_create(__CHATTERBOX_BUTTON.__SIZE);
        _button_array[ __CHATTERBOX_BUTTON.TEXT        ] = scribble_create(CHATTERBOX_DEFAULT_CONTINUE_TEXT);
        _button_array[ __CHATTERBOX_BUTTON.INSTRUCTION ] = _text_instruction;
        ds_list_add(_button_list, _button_array);
    }
    
    #endregion
    
    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Waiting...");
    
    #endregion
}
    
#region Make sure we have enough metadata slots laid out

var _text_count = ds_list_size(_text_list);
var _text_meta_count = ds_list_size(_text_meta_list);
var _count = _text_count - _text_meta_count
repeat (_count)
{
    var _x = 0;
    var _y = 0;
        
    var _new_array = array_create(CHATTERBOX_PROPERTY.__SIZE);
    _new_array[ CHATTERBOX_PROPERTY.X        ] = _x;
    _new_array[ CHATTERBOX_PROPERTY.Y        ] = _y;
    _new_array[ CHATTERBOX_PROPERTY.XY       ] = undefined;
    _new_array[ CHATTERBOX_PROPERTY.XSCALE   ] = CHATTERBOX_DEFAULT_TEXT_XSCALE;
    _new_array[ CHATTERBOX_PROPERTY.YSCALE   ] = CHATTERBOX_DEFAULT_TEXT_YSCALE;
    _new_array[ CHATTERBOX_PROPERTY.XY_SCALE ] = undefined;
    _new_array[ CHATTERBOX_PROPERTY.ANGLE    ] = CHATTERBOX_DEFAULT_TEXT_ANGLE;
    _new_array[ CHATTERBOX_PROPERTY.COLOUR   ] = CHATTERBOX_DEFAULT_TEXT_COLOUR;
    _new_array[ CHATTERBOX_PROPERTY.ALPHA    ] = CHATTERBOX_DEFAULT_TEXT_ALPHA;
    _new_array[ CHATTERBOX_PROPERTY.PMA      ] = CHATTERBOX_DEFAULT_TEXT_PMA;
    _new_array[ CHATTERBOX_PROPERTY.WIDTH    ] = undefined;
    _new_array[ CHATTERBOX_PROPERTY.HEIGHT   ] = undefined;
    ds_list_add(_text_meta_list, _new_array);
}

var _button_count = ds_list_size(_button_list);
var _button_meta_count = ds_list_size(_button_meta_list);
var _count = _button_count - _button_meta_count
repeat (_count)
{
    var _x = 0;
    var _y = 0;
    
    var _new_array = array_create(CHATTERBOX_PROPERTY.__SIZE);
    _new_array[ CHATTERBOX_PROPERTY.X        ] = _x;
    _new_array[ CHATTERBOX_PROPERTY.Y        ] = _y;
    _new_array[ CHATTERBOX_PROPERTY.XY       ] = undefined;
    _new_array[ CHATTERBOX_PROPERTY.XSCALE   ] = CHATTERBOX_DEFAULT_TEXT_XSCALE;
    _new_array[ CHATTERBOX_PROPERTY.YSCALE   ] = CHATTERBOX_DEFAULT_TEXT_YSCALE;
    _new_array[ CHATTERBOX_PROPERTY.XY_SCALE ] = undefined;
    _new_array[ CHATTERBOX_PROPERTY.ANGLE    ] = CHATTERBOX_DEFAULT_TEXT_ANGLE;
    _new_array[ CHATTERBOX_PROPERTY.COLOUR   ] = CHATTERBOX_DEFAULT_TEXT_COLOUR;
    _new_array[ CHATTERBOX_PROPERTY.ALPHA    ] = CHATTERBOX_DEFAULT_TEXT_ALPHA;
    _new_array[ CHATTERBOX_PROPERTY.PMA      ] = CHATTERBOX_DEFAULT_TEXT_PMA;
    _new_array[ CHATTERBOX_PROPERTY.WIDTH    ] = undefined;
    _new_array[ CHATTERBOX_PROPERTY.HEIGHT   ] = undefined;
    ds_list_add(_button_meta_list, _new_array);
}

#endregion

#region Automatic option position and colouring behaviours

if (CHATTERBOX_AUTO_HIGHLIGHT)
{
    var _count = chatterbox_text_get_number(chatterbox, true);
    for(var _i = 0; _i < _count; _i++)
    {
        var _highlighted = chatterbox_text_get(chatterbox, true, _i, CHATTERBOX_PROPERTY.HIGHLIGHTED);
        var _colour = _highlighted? CHATTERBOX_AUTO_HIGHLIGHT_ON_COLOUR : CHATTERBOX_AUTO_HIGHLIGHT_OFF_COLOUR;
        var _alpha  = _highlighted? CHATTERBOX_AUTO_HIGHLIGHT_ON_ALPHA  : CHATTERBOX_AUTO_HIGHLIGHT_OFF_ALPHA;
        
        chatterbox_text_set(chatterbox, true, _i, CHATTERBOX_PROPERTY.COLOUR, _colour);
        chatterbox_text_set(chatterbox, true, _i, CHATTERBOX_PROPERTY.ALPHA , _alpha);
    }
}

if (CHATTERBOX_AUTO_POSITION)
{
    //Control position and colour of options
    var _x_offset = chatterbox_text_get(chatterbox, false, 0, CHATTERBOX_PROPERTY.X)
                  + CHATTERBOX_AUTO_POSITION_OPTION_INDENT;
    
    var _y_offset = chatterbox_text_get(chatterbox, false, 0, CHATTERBOX_PROPERTY.Y)
                  + chatterbox_text_get(chatterbox, false, 0, CHATTERBOX_PROPERTY.HEIGHT)
                  + CHATTERBOX_AUTO_POSITION_TEXT_SEPARATION;
    
    var _count = chatterbox_text_get_number(chatterbox, true);
    for(var _i = 0; _i < _count; _i++)
    {
        chatterbox_text_set(chatterbox, true, _i, CHATTERBOX_PROPERTY.XY, _x_offset, _y_offset );
    
        _y_offset = chatterbox_text_get(chatterbox, true, _i, CHATTERBOX_PROPERTY.Y)
                  + chatterbox_text_get(chatterbox, true, _i, CHATTERBOX_PROPERTY.HEIGHT)
                  + CHATTERBOX_AUTO_POSITION_OPTION_SEPARATION;
    }
}

#endregion