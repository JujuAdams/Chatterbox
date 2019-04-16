/// @param json            The Chatterbox data structure to process
/// @param [selectOption] 
/// @param [stepSize]      The step size e.g. a delta time coefficient. Defaults to CHATTERBOX_DEFAULT_STEP_SIZE

var _chatterbox = argument[0];
var _select     = ((argument_count > 1) && (argument_count[1] != undefined))? argument[1] : undefined;
var _step_size  = ((argument_count > 2) && (argument_count[2] != undefined))? argument[2] : CHATTERBOX_DEFAULT_STEP_SIZE;



var _node_title        = _chatterbox[| __CHATTERBOX.TITLE        ];
var _filename          = _chatterbox[| __CHATTERBOX.FILENAME     ];
var _text_list         = _chatterbox[| __CHATTERBOX.TEXTS        ];
var _option_list       = _chatterbox[| __CHATTERBOX.OPTIONS      ];
var _text_meta_list    = _chatterbox[| __CHATTERBOX.TEXTS_META   ];
var _option_meta_list  = _chatterbox[| __CHATTERBOX.OPTIONS_META ];
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
    
    _highlighted_index = clamp(_highlighted_index, 0, ds_list_size(_option_list)-1);
    _chatterbox[| __CHATTERBOX.HIGHLIGHTED ] = _highlighted_index;
}

if (CHATTERBOX_AUTO_MOUSE)
{
    var _count = ds_list_size(_option_list);
    for(var _i = 0; _i < _count; _i++)
    {
        var _array = _option_list[| _i ];
        var _scribble = _array[ __CHATTERBOX_OPTION.TEXT ];
        
        var _meta_array = _option_meta_list[| _i ];
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
    
    if (!CHATTERBOX_AUTO_KEYBOARD || (_i < _count)) _select = CHATTERBOX_AUTO_MOUSE_SELECT;
}

#endregion



//Perform a step for all nested Scribble data structures
for(var _i = ds_list_size(_text_list  )-1; _i >= 0; _i--) scribble_step(_text_list[| _i], _step_size);
for(var _i = ds_list_size(_option_list)-1; _i >= 0; _i--)
{
    var _option_array = _option_list[| _i];
    scribble_step(_option_array[ __CHATTERBOX_OPTION.TEXT ], _step_size);
}



//VM state
var _key                   = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
var _indent                = 0;
var _indent_bottom_limit   = undefined;
var _text_instruction      = 0;
var _instruction           = global.__chatterbox_goto[? _key ];
var _end_instruction       = -1;
var _scan_from_text        = false;
var _scan_from_option      = false;
var _if_state              = true;
var _permit_greater_indent = false;



var _evaluate = false;
if (!_chatterbox[| __CHATTERBOX.INITIALISED])
{
    #region Handle chatterboxes that haven't been initialised yet
    _chatterbox[| __CHATTERBOX.INITIALISED ] = true;
    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Initialising");
    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set instruction = " + string(_instruction));
    
    //If this chatterbox hasn't been initialised skip straight to evaluation
    _evaluate = true;
    
    var _instruction_array = global.__chatterbox_vm[| _instruction];
        _indent            = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
    
    #endregion
}
else
{
    #region Advance to the next instruction if the player has selected an option
    
    if (_select && (_highlighted_index != undefined))
    {
        _chatterbox[| __CHATTERBOX.HIGHLIGHTED ] = 0;
        
        var _option_meta_array = _option_list[| _highlighted_index ];
        var _instruction     = _option_meta_array[ __CHATTERBOX_OPTION.START_INSTRUCTION ];
        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set instruction = " + string(_instruction));
        var _end_instruction = _option_meta_array[ __CHATTERBOX_OPTION.END_INSTRUCTION   ];
        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set end instruction = " + string(_end_instruction));
        
        _scan_from_option = true;
        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set _scan_from_option=" + string(_scan_from_option));
        
        var _option_array   = global.__chatterbox_vm[| _instruction];
        var _indent         = _option_array[ __CHATTERBOX_INSTRUCTION.INDENT  ];
        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
        var _option_content = _option_array[ __CHATTERBOX_INSTRUCTION.CONTENT ];
        
        show_debug_message("Chatterbox: Starting scan from " + string(_highlighted_index) + ", \"" + string(_option_content[0]) + "\"");
        
        //Advance to the next instruction
        _instruction++;
        
        _evaluate = true;
    }
    
    #endregion
}



if (_evaluate)
{
    __chatterbox_destroy_children(_chatterbox);
    
    #region Evaluate Yarn virtual machine
    
    var _break = false;
    repeat(9999)
    {
        var _continue = false;
        if (_instruction < 0)
        {
            _instruction++;
            continue;
        }
        
        var _instruction_array   = global.__chatterbox_vm[| _instruction ];
        var _instruction_type    = _instruction_array[ __CHATTERBOX_INSTRUCTION.TYPE    ];
        var _instruction_indent  = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT  ];
        var _instruction_content = _instruction_array[ __CHATTERBOX_INSTRUCTION.CONTENT ];
        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   " + _instruction_type + ":   " + string(_instruction_indent) + ":   " + string(_instruction_content));
        
        if (_scan_from_option)
        {
            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_option == " + string(_scan_from_option));
            
            if (_instruction >= _end_instruction)
            {
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction " + string(_instruction) + " >= end " + string(_end_instruction));
                _indent = _instruction_indent;
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set indent = " + string(_indent));
                _scan_from_option = false;
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set _scan_from_option=" + string(_scan_from_option));
            }
        }
        
        #region Identation behaviours
        
        if (_instruction_indent < _indent)
        {
            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction indent " + string(_instruction_indent) + " < indent " + string(_indent));
            if (!_scan_from_text)
            {
                _indent = _instruction_indent;
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set indent = " + string(_indent));
            }
            else if ((_indent_bottom_limit != undefined) && (_instruction_indent < _indent_bottom_limit))
            {
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       instruction indent " + string(_instruction_indent) + " < _indent_bottom_limit " + string(_indent_bottom_limit));
                _break = true;
                if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":         Break");
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
            #region Execute instructions
            
            var _new_option      = false;
            var _new_option_text = "";
            switch(_instruction_type)
            {
                case __CHATTERBOX_VM_TEXT:
                    #region Text
                    
                    if (_scan_from_text)
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                        _break = true;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Break");
                        break;
                    }
                    
                    _scan_from_text = true;
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _scan_from_text = " + string(_scan_from_text));
                    
                    var _text = scribble_create(_instruction_content[0],
                                                CHATTERBOX_TEXT_CREATE_LINE_MIN_HEIGHT,
                                                CHATTERBOX_TEXT_CREATE_MAX_WIDTH,
                                                CHATTERBOX_TEXT_CREATE_DEFAULT_COLOUR,
                                                CHATTERBOX_TEXT_CREATE_DEFAULT_FONT,
                                                CHATTERBOX_TEXT_CREATE_DEFAULT_HALIGN,
                                                CHATTERBOX_TEXT_CREATE_DATA_FIELDS);
                    ds_list_insert(_text_list, 0, _text);
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Created text");
                    
                    var _text_instruction = _instruction; //Record the instruction position of the text
                    
                    _indent_bottom_limit = _instruction_indent;
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _indent_for_options = " + string(_indent_bottom_limit));
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_REDIRECT:
                    #region Redirect
                    
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                    if (_scan_from_text)
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Break");
                        _break = true;
                        break;
                    }
                    else
                    {
                        _node_title = _instruction_content[0];
                        _chatterbox[| __CHATTERBOX.TITLE ] = _node_title;
                        
                        var _key = _node_title; //_filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Redirecting to " + string(_key) );
                        
                        //Partially reset state
                        var _indent                = 0;
                        var _indent_bottom_limit   = 0;
                        var _text_instruction      = 0;
                        var _instruction           = global.__chatterbox_goto[? _key ];
                        var _end_instruction       = -1;
                        var _if_state              = true;
                        var _permit_greater_indent = false;
                        
                        _continue = true;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Continue");
                        break;
                    }
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_OPTION:
                    #region Option
                    
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                    if (!_scan_from_text)
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction=" + string(_instruction) + " vs. end=" + string(_end_instruction));
                        if (_instruction == _end_instruction)
                        {
                            _node_title = _instruction_content[1];
                            _chatterbox[| __CHATTERBOX.TITLE ] = _node_title;
                            
                            var _key = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
                            
                            //Partially reset state
                            var _text_instruction      = -1;
                            var _instruction           = global.__chatterbox_goto[? _key ]-1;
                            var _end_instruction       = -1;
                            var _if_state              = true;
                            var _permit_greater_indent = false;
                            
                            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Jumping to " + string(_key) + ", instruction = " + string(_instruction) + " (inc. -1 offset)" );
                            
                            var _instruction_array   = global.__chatterbox_vm[| _instruction+1];
                                _indent              = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
                                _indent_bottom_limit = 0;
                            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
                        }
                        
                        _continue = true;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Continue");
                        break;
                    }
                    
                    _indent_bottom_limit = _instruction_indent;
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _indent_for_options = " + string(_indent_bottom_limit));
                    
                    _new_option = true;
                    _new_option_text = _instruction_content[0];
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     New option \"" + string(_new_option_text) + "\"");
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_SHORTCUT:
                    #region Shortcut
                    
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       _scan_from_text == " + string(_scan_from_text));
                    if (!_scan_from_text)
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction=" + string(_instruction) + " vs. end=" + string(_end_instruction));
                        if (_instruction == _end_instruction)
                        {
                            _permit_greater_indent = true;
                            if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   Set _permit_greater_indent = " + string(_permit_greater_indent));
                        }
                        
                        _continue = true;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Continue");
                        break;
                    }
                    
                    _indent_bottom_limit = _instruction_indent;
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _indent_for_options = " + string(_indent_bottom_limit));
                    
                    _new_option = true;
                    _new_option_text = _instruction_content[0];
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       New option \"" + string(_new_option_text) + "\"");
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_SET:
                    #region Set
                    
                    if (_scan_from_text)
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                        _continue = true;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Continue");
                        break;
                    }
                    
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     now executing");
                    __chatterbox_evaluate(_chatterbox, _instruction_content);
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_CUSTOM_ACTION:
                    #region Custom Action
                    
                    if (_scan_from_text)
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                        _continue = true;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Continue");
                        break;
                    }
                    
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
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_STOP:
                    #region Stop
                    
                    if (_scan_from_text)
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Break");
                        _break = true;
                        break;
                    }
                    
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                    chatterbox_stop(_chatterbox);
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Stop");
                    exit;
                    
                    #endregion
                break;
            }
            
            #endregion
        
            #region Create a new option from SHORTCUT and OPTION instructions
            
            if (_new_option)
            {
                _new_option = false;
                
                var _scribble = scribble_create(_new_option_text,
                                                CHATTERBOX_OPTION_CREATE_LINE_MIN_HEIGHT,
                                                CHATTERBOX_OPTION_CREATE_MAX_WIDTH,
                                                CHATTERBOX_OPTION_CREATE_DEFAULT_COLOUR,
                                                CHATTERBOX_OPTION_CREATE_DEFAULT_FONT,
                                                CHATTERBOX_OPTION_CREATE_DEFAULT_HALIGN,
                                                CHATTERBOX_OPTION_CREATE_DATA_FIELDS);
                
                var _option_array = array_create(__CHATTERBOX_OPTION.__SIZE);
                _option_array[@ __CHATTERBOX_OPTION.TEXT              ] = _scribble;
                _option_array[@ __CHATTERBOX_OPTION.START_INSTRUCTION ] = _text_instruction;
                _option_array[@ __CHATTERBOX_OPTION.END_INSTRUCTION   ] = _instruction;
                ds_list_add(_option_list, _option_array);
            }
            #endregion
        }
        
        if (_break) break;
        
        _instruction++;
    }
    
    #region Create a new option from a TEXT instruction if no option or shortcut was found
    
    if (ds_list_size(_option_list) <= 0)
    {  
        var _scribble = scribble_create(CHATTERBOX_OPTION_DEFAULT_TEXT,
                                        CHATTERBOX_OPTION_CREATE_LINE_MIN_HEIGHT,
                                        CHATTERBOX_OPTION_CREATE_MAX_WIDTH,
                                        CHATTERBOX_OPTION_CREATE_DEFAULT_COLOUR,
                                        CHATTERBOX_OPTION_CREATE_DEFAULT_FONT,
                                        CHATTERBOX_OPTION_CREATE_DEFAULT_HALIGN,
                                        CHATTERBOX_OPTION_CREATE_DATA_FIELDS);
        
        var _option_array = array_create(__CHATTERBOX_OPTION.__SIZE);
        _option_array[@ __CHATTERBOX_OPTION.TEXT              ] = _scribble;
        _option_array[@ __CHATTERBOX_OPTION.START_INSTRUCTION ] = _text_instruction;
        _option_array[@ __CHATTERBOX_OPTION.END_INSTRUCTION   ] = _text_instruction;
        ds_list_add(_option_list, _option_array);
    }
    
    #endregion
    
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
    _new_array[@ CHATTERBOX_PROPERTY.__SECTION0  ] = "-- Internal --";
    _new_array[@ CHATTERBOX_PROPERTY.X           ] = _x;
    _new_array[@ CHATTERBOX_PROPERTY.Y           ] = _y;
    _new_array[@ CHATTERBOX_PROPERTY.XY          ] = undefined;
    _new_array[@ CHATTERBOX_PROPERTY.XSCALE      ] = CHATTERBOX_TEXT_DRAW_DEFAULT_XSCALE;
    _new_array[@ CHATTERBOX_PROPERTY.YSCALE      ] = CHATTERBOX_TEXT_DRAW_DEFAULT_YSCALE;
    _new_array[@ CHATTERBOX_PROPERTY.XY_SCALE    ] = undefined;
    _new_array[@ CHATTERBOX_PROPERTY.ANGLE       ] = CHATTERBOX_TEXT_DRAW_DEFAULT_ANGLE;
    _new_array[@ CHATTERBOX_PROPERTY.BLEND       ] = CHATTERBOX_TEXT_DRAW_DEFAULT_BLEND;
    _new_array[@ CHATTERBOX_PROPERTY.ALPHA       ] = CHATTERBOX_TEXT_DRAW_DEFAULT_ALPHA;
    _new_array[@ CHATTERBOX_PROPERTY.PMA         ] = CHATTERBOX_TEXT_DRAW_DEFAULT_PMA;
    _new_array[@ CHATTERBOX_PROPERTY.WIDTH       ] = undefined;
    _new_array[@ CHATTERBOX_PROPERTY.__SECTION1  ] = "-- Read-Only Properties --";
    _new_array[@ CHATTERBOX_PROPERTY.HEIGHT      ] = undefined;
    _new_array[@ CHATTERBOX_PROPERTY.SCRIBBLE    ] = undefined;
    _new_array[@ CHATTERBOX_PROPERTY.HIGHLIGHTED ] = undefined;
    ds_list_add(_text_meta_list, _new_array);
}

var _option_count = ds_list_size(_option_list);
var _option_meta_count = ds_list_size(_option_meta_list);
var _count = _option_count - _option_meta_count
repeat (_count)
{
    var _x = 0;
    var _y = 0;
    
    var _new_array = array_create(CHATTERBOX_PROPERTY.__SIZE);
    _new_array[@ CHATTERBOX_PROPERTY.__SECTION0  ] = "-- Internal --";
    _new_array[@ CHATTERBOX_PROPERTY.X           ] = _x;
    _new_array[@ CHATTERBOX_PROPERTY.Y           ] = _y;
    _new_array[@ CHATTERBOX_PROPERTY.XY          ] = undefined;
    _new_array[@ CHATTERBOX_PROPERTY.XSCALE      ] = CHATTERBOX_TEXT_DRAW_DEFAULT_XSCALE;
    _new_array[@ CHATTERBOX_PROPERTY.YSCALE      ] = CHATTERBOX_TEXT_DRAW_DEFAULT_YSCALE;
    _new_array[@ CHATTERBOX_PROPERTY.XY_SCALE    ] = undefined;
    _new_array[@ CHATTERBOX_PROPERTY.ANGLE       ] = CHATTERBOX_TEXT_DRAW_DEFAULT_ANGLE;
    _new_array[@ CHATTERBOX_PROPERTY.BLEND       ] = CHATTERBOX_TEXT_DRAW_DEFAULT_BLEND;
    _new_array[@ CHATTERBOX_PROPERTY.ALPHA       ] = CHATTERBOX_TEXT_DRAW_DEFAULT_ALPHA;
    _new_array[@ CHATTERBOX_PROPERTY.PMA         ] = CHATTERBOX_TEXT_DRAW_DEFAULT_PMA;
    _new_array[@ CHATTERBOX_PROPERTY.WIDTH       ] = undefined;
    _new_array[@ CHATTERBOX_PROPERTY.__SECTION1  ] = "-- Read-Only Properties --";
    _new_array[@ CHATTERBOX_PROPERTY.HEIGHT      ] = undefined;
    _new_array[@ CHATTERBOX_PROPERTY.SCRIBBLE    ] = undefined;
    _new_array[@ CHATTERBOX_PROPERTY.HIGHLIGHTED ] = undefined;
    ds_list_add(_option_meta_list, _new_array);
}

#endregion

#region Automatic option position and colouring behaviours

if (CHATTERBOX_AUTO_HIGHLIGHT)
{
    var _count = chatterbox_text_get_number(chatterbox, true);
    for(var _i = 0; _i < _count; _i++)
    {
        var _highlighted = chatterbox_text_get(chatterbox, true, _i, CHATTERBOX_PROPERTY.HIGHLIGHTED);
        _highlighted = (_highlighted == undefined)? false : _highlighted;
        var _colour = _highlighted? CHATTERBOX_AUTO_HIGHLIGHT_ON_COLOUR : CHATTERBOX_AUTO_HIGHLIGHT_OFF_COLOUR;
        var _alpha  = _highlighted? CHATTERBOX_AUTO_HIGHLIGHT_ON_ALPHA  : CHATTERBOX_AUTO_HIGHLIGHT_OFF_ALPHA;
        
        chatterbox_text_set(chatterbox, true, _i, CHATTERBOX_PROPERTY.BLEND, _colour);
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