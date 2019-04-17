/// @param json            The Chatterbox data structure to process
/// @param [forceSelect] 
/// @param [stepSize]      The step size e.g. a delta time coefficient. Defaults to CHATTERBOX_DEFAULT_STEP_SIZE

var _chatterbox   = argument[0];
var _force_select = ((argument_count > 1) && (argument_count[1] != undefined))? argument[1] : false;
var _step_size    = ((argument_count > 2) && (argument_count[2] != undefined))? argument[2] : CHATTERBOX_DEFAULT_STEP_SIZE;

var _node_title        = _chatterbox[| __CHATTERBOX.TITLE           ];
var _filename          = _chatterbox[| __CHATTERBOX.FILENAME        ];
var _selected          = _chatterbox[| __CHATTERBOX.SELECTED        ];
var _highlighted_index = _chatterbox[| __CHATTERBOX.HIGHLIGHTED     ];
var _iteration         = _chatterbox[| __CHATTERBOX.ITERATION       ];
var _text_list         = _chatterbox[| __CHATTERBOX.TEXT_LIST       ];
var _option_list       = _chatterbox[| __CHATTERBOX.OPTION_LIST     ];
var _old_text_list     = _chatterbox[| __CHATTERBOX.OLD_TEXT_LIST   ];
var _old_option_list   = _chatterbox[| __CHATTERBOX.OLD_OPTION_LIST ];
var _variables_map     = __CHATTERBOX_VARIABLE_MAP;

var _selected = _selected || _force_select;



var _all_text_faded_in     = true;
var _all_options_faded_in  = true;

var _text_size       = ds_list_size(_text_list);
var _option_size     = ds_list_size(_option_list);
var _old_text_size   = ds_list_size(_old_text_list);
var _old_option_size = ds_list_size(_old_option_list);

#region Find the fade state of every child

for(var _i = 0; _i < _text_size; _i++)
{
    var _array = _text_list[| _i];
    var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
    if (_scribble == undefined) continue;
    var _state = scribble_typewriter_get_state(_scribble);
    if ((_state != undefined) && (_state < 1)) _all_text_faded_in = false;
}

for(var _i = 0; _i < _option_size; _i++)
{
    var _array = _option_list[| _i];
    var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
    if (_scribble == undefined) continue;
    var _state = scribble_typewriter_get_state(_scribble);
    if ((_state != undefined) && (_state < 1)) _all_options_faded_in = false;
}

#endregion

#region Stop options from being highlighted if they've not all finished fading in

if (!_all_options_faded_in && CHATTERBOX_FADING_OPTIONS_NO_HIGHLIGHT)
{
    _highlighted_index = undefined;
    _chatterbox[| __CHATTERBOX.HIGHLIGHTED ] = _highlighted_index
}
else
{
    if (_highlighted_index == undefined)
    {
        _highlighted_index = 0;
        _chatterbox[| __CHATTERBOX.HIGHLIGHTED ] = _highlighted_index
    }
}

#endregion

#region Skip fading if we're able to

if (CHATTERBOX_SKIP_FADE_ON_SELECT && _selected && (!_all_text_faded_in || !_all_options_faded_in))
{
    _selected = false;
    
    for(var _i = 0; _i < _text_size; _i++)
    {
        var _array = _text_list[| _i];
        var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
        if (_scribble == undefined) continue;
        
        scribble_typewriter_out(_scribble, undefined, 0);
    }
    
    for(var _i = 0; _i < _option_size; _i++)
    {
        var _array = _option_list[| _i];
        var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
        if (_scribble == undefined) continue;
        
        scribble_typewriter_out(_scribble, undefined, 0);
    }
}

#endregion

#region Perform step for each text child

for(var _i = 0; _i < _text_size; _i++)
{
    var _array = _text_list[| _i];
    var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
    if (_scribble == undefined) continue;
    scribble_step(_scribble, _step_size);
}

for(var _i = 0; _i < _option_size; _i++)
{
    var _array = _option_list[| _i];
    var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
    if (_scribble == undefined) continue;
    scribble_step(_scribble, _step_size);
}

for(var _i = 0; _i < _old_text_size; _i++)
{
    var _array = _old_text_list[| _i];
    scribble_step(_array[ CHATTERBOX_PROPERTY.SCRIBBLE ], _step_size);
}

for(var _i = 0; _i < _old_option_size; _i++)
{
    var _array = _old_option_list[| _i];
    scribble_step(_array[ CHATTERBOX_PROPERTY.SCRIBBLE ], _step_size);
}

#endregion

#region Destroy any old children that have finished fading out

if (CHATTERBOX_AUTO_DESTROY_FADED_OUT_TEXT)
{
    for(var _i = _old_text_size-1; _i >= 0; _i--)
    {
        var _array = _old_text_list[| _i];
        var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
        
        var _state = scribble_typewriter_get_state(_scribble);
        if ((_state == undefined) || (_state >= 2))
        {
            scribble_destroy(_scribble);
            ds_list_delete(_old_text_list, _i);
        }
    }
}

if (CHATTERBOX_AUTO_DESTROY_FADED_OUT_OPTIONS)
{
    for(var _i = _old_option_size-1; _i >= 0; _i--)
    {
        var _array = _old_option_list[| _i];
        var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
        
        var _state = scribble_typewriter_get_state(_scribble);
        if ((_state == undefined) || (_state >= 2))
        {
            scribble_destroy(_scribble);
            ds_list_delete(_old_option_list, _i);
        }
    }
}

#endregion



if (_node_title == undefined)
{
    //If the node title is <undefined> then this chatterbox has been stopped
    exit;
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
var _scan_from_option_end  = false;
var _if_state              = true;
var _permit_greater_indent = false;



var _evaluate = false;
if (!_chatterbox[| __CHATTERBOX.INITIALISED])
{
    #region Handle chatterboxes that haven't been initialised yet
    
    _chatterbox[| __CHATTERBOX.INITIALISED ] = true;
    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Initialising");
    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set instruction = " + string(_instruction));
    
    //If this chatterbox hasn't been initialised skip straight to evaluation
    _evaluate = true;
    
    var _instruction_array = global.__chatterbox_vm[| _instruction];
        _indent            = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
    
    #endregion
}
else
{
    #region Advance to the next instruction if the player has selected an option
    
    if (_selected && (_highlighted_index != undefined) && (_all_options_faded_in || !CHATTERBOX_FADING_OPTIONS_NO_SELECT))
    {
        _chatterbox[| __CHATTERBOX.HIGHLIGHTED ] = 0;
        
        var _array = _option_list[| _highlighted_index ];
        var _instruction     = _array[ CHATTERBOX_PROPERTY.__INSTRUCTION0 ];
        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set instruction = " + string(_instruction));
        var _end_instruction = _array[ CHATTERBOX_PROPERTY.__INSTRUCTION1 ];
        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set end instruction = " + string(_end_instruction));
        
        _scan_from_option = true;
        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set _scan_from_option=" + string(_scan_from_option));
        
        var _array  = global.__chatterbox_vm[| _instruction ];
        var _indent = _array[ __CHATTERBOX_INSTRUCTION.INDENT ];
        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
        
        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Starting scan from option index=" + string(_highlighted_index) + ", \"" + string(_array[ __CHATTERBOX_INSTRUCTION.CONTENT ]) + "\"");
        
        //Advance to the next instruction
        _instruction++;
        
        _evaluate = true;
    }
    
    #endregion
}

_chatterbox[| __CHATTERBOX.SELECTED ] = false;



if (_evaluate)
{
    #region Move current children to "old" lists
    
    var _text_size = ds_list_size(_text_list);
    for(var _i = 0; _i < _text_size; _i++)
    {
        var _array = _text_list[| _i];
        var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
        if (_scribble == undefined) continue;
        
        if (_chatterbox[| __CHATTERBOX.SUSPENDED ])
        {
            scribble_destroy(_scribble);
        }
        else
        {
            var _new_array = array_create(CHATTERBOX_PROPERTY.__SIZE);
            array_copy(_new_array, 0, _array, 0, CHATTERBOX_PROPERTY.__SIZE);
            ds_list_add(_old_text_list, _new_array);
        }
        
        _array[@ CHATTERBOX_PROPERTY.SCRIBBLE ] = undefined;
    }
    
    var _option_size = ds_list_size(_option_list);
    for(var _i = 0; _i < _option_size; _i++)
    {
        var _array = _option_list[| _i];
        var _scribble = _array[ CHATTERBOX_PROPERTY.SCRIBBLE ];
        if (_scribble == undefined) continue;
        
        if (_chatterbox[| __CHATTERBOX.SUSPENDED ])
        {
            scribble_destroy(_scribble);
        }
        else
        {
            var _new_array = array_create(CHATTERBOX_PROPERTY.__SIZE);
            array_copy(_new_array, 0, _array, 0, CHATTERBOX_PROPERTY.__SIZE);
            ds_list_add(_old_option_list, _new_array);
        }
        
        _array[@ CHATTERBOX_PROPERTY.SCRIBBLE ] = undefined;
    }
    
    #endregion
    
    _iteration++;
    _chatterbox[| __CHATTERBOX.ITERATION ] = _iteration;
    _chatterbox[| __CHATTERBOX.SUSPENDED ] = false;
    
    #region Run virtual machine
    
    var _break = false;
    repeat(9999)
    {
        var _continue = false;
            _scan_from_option_end = false;
        
        var _instruction_array   = global.__chatterbox_vm[| _instruction ];
        var _instruction_type    = _instruction_array[ __CHATTERBOX_INSTRUCTION.TYPE    ];
        var _instruction_indent  = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT  ];
        var _instruction_content = _instruction_array[ __CHATTERBOX_INSTRUCTION.CONTENT ];
        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   " + _instruction_type + ":   " + string(_instruction_indent) + ":   " + string(_instruction_content));
        
        if (_scan_from_option)
        {
            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_option == " + string(_scan_from_option));
            
            if (_instruction == _end_instruction)
            {
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction " + string(_instruction) + " == end " + string(_end_instruction));
                _indent = _instruction_indent;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set indent = " + string(_indent));
                _scan_from_option = false;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set _scan_from_option=" + string(_scan_from_option));
                _scan_from_option_end = true;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set _scan_from_option_end=" + string(_scan_from_option_end));
            }
            else if (_instruction > _end_instruction)
            {
                show_error("Chatterbox:\nVM instruction overstepped bounds!\n ", true);
                _instruction = _end_instruction;
                continue;
            }
        }
        
        #region Identation behaviours
        
        if (_instruction_indent < _indent)
        {
            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction indent " + string(_instruction_indent) + " < indent " + string(_indent));
            if (!_scan_from_text)
            {
                _indent = _instruction_indent;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set indent = " + string(_indent));
            }
            else if ((_indent_bottom_limit != undefined) && (_instruction_indent < _indent_bottom_limit))
            {
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       instruction indent " + string(_instruction_indent) + " < _indent_bottom_limit " + string(_indent_bottom_limit));
                _break = true;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   -> BREAK ->");
            }
        }
        else if (_instruction_indent > _indent)
        {
            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction indent " + string(_instruction_indent) + " > indent " + string(_indent));
            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       _permit_greater_indent=" + string(_permit_greater_indent));
            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       indent difference=" + string(_instruction_indent - _indent));
            if (_permit_greater_indent && ((_instruction_indent - _indent) <= CHATTERBOX_TAB_INDENT_SIZE))
            {
                _indent = _instruction_indent;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":         Set indent = " + string(_indent));
            }
            else
            {
                _continue = true;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
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
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _if_state == " + string(_if_state));
                            _continue = true;
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                            break;
                        }
                    }
                    
                    //Only evaluate the elseif-statement if we failed the previous check
                    if (_instruction_type == __CHATTERBOX_VM_ELSEIF)
                    {
                        if (_if_state)
                        {
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _if_state == " + string(_if_state));
                            _if_state = false;
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set _if_state = " + string(_if_state));
                            _continue = true;
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                            break;
                        }
                    }
                    
                    var _result = __chatterbox_evaluate(_chatterbox, _instruction_content);
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   Evaluator returned \"" + string(_result) + "\" (" + typeof(_result) + ")");
                    
                    if (!is_bool(_result) && !is_real(_result))
                    {
                        show_debug_message("Chatterbox: WARNING! Expression evaluator returned an invalid datatype (" + typeof(_result) + ")");
                        var _if_state = false;
                    }
                    else
                    {
                        var _if_state = _result;
                    }
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   Set _if_state = " + string(_if_state));
                    
                    if (_if_state)
                    {
                        _permit_greater_indent = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   Set _permit_greater_indent = " + string(_permit_greater_indent));
                    }
                break;
                
                case __CHATTERBOX_VM_ELSE:
                    _if_state = !_if_state;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Invert _if_state = " + string(_if_state));
                    
                    if (_if_state)
                    {
                        _permit_greater_indent = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _permit_greater_indent = " + string(_permit_greater_indent));
                    }
                break;
                
                case __CHATTERBOX_VM_IF_END:
                    _if_state = true;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _if_state = " + string(_if_state));
                break;
            }
            
        }
        
        if (!_break && !_continue)
        {
            //If we're inside a branch that has been evaluated as <false> then keep skipping until we close the branch
            if (!_if_state)
            {
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   _if_state == " + string(_if_state));
                _continue = true;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
            }
        }
        
        #endregion
        
        if (!_break && !_continue)
        {
            var _new_option      = false;
            var _new_option_text = "";
            switch(_instruction_type)
            {
                case __CHATTERBOX_VM_WAIT:
                    #region Wait
                    
                    if (_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                        _break = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   -> BREAK ->");
                        break;
                    }
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_TEXT:
                    #region Text
                    
                    if (_scan_from_text && CHATTERBOX_SINGLETON_TEXT)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                        _break = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   -> BREAK ->");
                        break;
                    }
                    
                    _scan_from_text = true;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _scan_from_text = " + string(_scan_from_text));
                    
                    var _scribble = scribble_create(_instruction_content[0],
                                                    _chatterbox[| __CHATTERBOX.TEXT_MIN_LINE_HEIGHT ],
                                                    _chatterbox[| __CHATTERBOX.TEXT_MAX_LINE_WIDTH  ],
                                                    _chatterbox[| __CHATTERBOX.TEXT_STARTING_COLOUR ],
                                                    _chatterbox[| __CHATTERBOX.TEXT_STARTING_FONT   ],
                                                    _chatterbox[| __CHATTERBOX.TEXT_STARTING_HALIGN ],
                                                    _chatterbox[| __CHATTERBOX.TEXT_DATA_FIELDS     ]);
                    
                    
                    
                    var _size = ds_list_size(_text_list);
                    for(var _replace_index = 0; _replace_index < _size; _replace_index++)
                    {
                        var _array = _text_list[| _replace_index];
                        if (_array[ CHATTERBOX_PROPERTY.SCRIBBLE ] == undefined) break;
                    }
                    
                    if (_replace_index < _size)
                    {
                        _array[@ CHATTERBOX_PROPERTY.ITERATION ] = _iteration;
                        _array[@ CHATTERBOX_PROPERTY.SCRIBBLE  ] = _scribble;
                    }
                    else
                    {
                        //If we've got no existing text to use as a template, create one!
                        var _new_array = array_create(CHATTERBOX_PROPERTY.__SIZE);
                        _new_array[@ CHATTERBOX_PROPERTY.X              ] = 0;
                        _new_array[@ CHATTERBOX_PROPERTY.Y              ] = 0;
                        _new_array[@ CHATTERBOX_PROPERTY.XY             ] = undefined;
                        _new_array[@ CHATTERBOX_PROPERTY.XSCALE         ] = CHATTERBOX_TEXT_DRAW_DEFAULT_XSCALE;
                        _new_array[@ CHATTERBOX_PROPERTY.YSCALE         ] = CHATTERBOX_TEXT_DRAW_DEFAULT_YSCALE;
                        _new_array[@ CHATTERBOX_PROPERTY.XY_SCALE       ] = undefined;
                        _new_array[@ CHATTERBOX_PROPERTY.ANGLE          ] = CHATTERBOX_TEXT_DRAW_DEFAULT_ANGLE;
                        _new_array[@ CHATTERBOX_PROPERTY.BLEND          ] = CHATTERBOX_TEXT_DRAW_DEFAULT_BLEND;
                        _new_array[@ CHATTERBOX_PROPERTY.ALPHA          ] = CHATTERBOX_TEXT_DRAW_DEFAULT_ALPHA;
                        _new_array[@ CHATTERBOX_PROPERTY.PMA            ] = CHATTERBOX_TEXT_DRAW_DEFAULT_PMA;
                        _new_array[@ CHATTERBOX_PROPERTY.HIGHLIGHTABLE  ] = true;
                        _new_array[@ CHATTERBOX_PROPERTY.SELECTABLE     ] = true;
                        _new_array[@ CHATTERBOX_PROPERTY.__SECTION0     ] = "-- Read-Only Properties --";
                        _new_array[@ CHATTERBOX_PROPERTY.ITERATION      ] = _iteration;
                        _new_array[@ CHATTERBOX_PROPERTY.WIDTH          ] = undefined;
                        _new_array[@ CHATTERBOX_PROPERTY.HEIGHT         ] = undefined;
                        _new_array[@ CHATTERBOX_PROPERTY.SCRIBBLE       ] = _scribble;
                        _new_array[@ CHATTERBOX_PROPERTY.HIGHLIGHTED    ] = undefined;
                        _new_array[@ CHATTERBOX_PROPERTY.__INSTRUCTION0 ] = undefined;
                        _new_array[@ CHATTERBOX_PROPERTY.__INSTRUCTION1 ] = undefined;
                        ds_list_add(_text_list, _new_array);
                    }
                    
                    
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Created text");
                    
                    var _text_instruction = _instruction; //Record the instruction position of the text
                    
                    _indent_bottom_limit = _instruction_indent;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _indent_for_options = " + string(_indent_bottom_limit));
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_REDIRECT:
                    #region Redirect
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                    if (_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   -> BREAK ->");
                        _break = true;
                        break;
                    }
                    else
                    {
                        var _string = _instruction_content[0];
                        var _pos = string_pos(CHATTERBOX_FILENAME_SEPARATOR, _string);
                        if (_pos > 0)
                        {
                            _filename   = string_copy(_string, 1, _pos-1);
                            _node_title = string_delete(_string, 1, _pos);
                        }
                        else
                        {
                            _node_title = _string;
                        }
                        
                        _chatterbox[| __CHATTERBOX.TITLE    ] = _node_title;
                        _chatterbox[| __CHATTERBOX.FILENAME ] = _filename;
                        
                        var _key = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
                        _variables_map[? "visited(" + _key + ")" ] = true;
                        if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox:   Set \"visited(" + _key + ")\" to <true>");
                        
                        if (!ds_map_exists(global.__chatterbox_goto, _key))
                        {
                            if (!ds_map_exists(global.__chatterbox_file_data, _filename))
                            {
                                show_error("Chatterbox:\nFile \"" + string(_filename) + "\" not initialised.\n ", true);
                                exit;
                            }
                            else
                            {
                                show_error("Chatterbox:\nNode title \"" + string(_node_title) + "\" not found in file \"" + string(_filename) + "\".\n ", true);
                                exit;
                            }
                        }
                        
                        //Partially reset state
                        var _text_instruction      = -1;
                        var _instruction           = global.__chatterbox_goto[? _key ]-1;
                        var _end_instruction       = -1;
                        var _if_state              = true;
                        var _permit_greater_indent = false;
                        var _scan_from_option_end  = false;
                        
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Jumping to " + string(_key) + ", instruction = " + string(_instruction) + " (inc. -1 offset)" );
                        
                        var _instruction_array   = global.__chatterbox_vm[| _instruction+1];
                            _indent              = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
                            _indent_bottom_limit = 0;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
                        
                        _continue = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                        break;
                    }
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_OPTION:
                    #region Option
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                    if (!_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_option_end == " + string(_scan_from_option_end));
                        if (_scan_from_option_end)
                        {
                            _node_title = _instruction_content[1];
                            _chatterbox[| __CHATTERBOX.TITLE ] = _node_title;
                            
                            var _key = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
                            _variables_map[? "visited(" + _key + ")" ] = true;
                            if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox:   Set \"visited(" + _key + ")\" to <true>");
                        
                            if (!ds_map_exists(global.__chatterbox_goto, _key))
                            {
                                if (!ds_map_exists(global.__chatterbox_file_data, _filename))
                                {
                                    show_error("Chatterbox:\nFile \"" + string(_filename) + "\" not initialised.\n ", true);
                                    exit;
                                }
                                else
                                {
                                    show_error("Chatterbox:\nNode title \"" + string(_node_title) + "\" not found in file \"" + string(_filename) + "\".\n ", true);
                                    exit;
                                }
                            }
                            
                            //Partially reset state
                            var _text_instruction      = -1;
                            var _instruction           = global.__chatterbox_goto[? _key ]-1;
                            var _end_instruction       = -1;
                            var _if_state              = true;
                            var _permit_greater_indent = false;
                            var _scan_from_option_end  = false;
                            
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Jumping to " + string(_key) + ", instruction = " + string(_instruction) + " (inc. -1 offset)" );
                            
                            var _instruction_array   = global.__chatterbox_vm[| _instruction+1];
                                _indent              = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
                                _indent_bottom_limit = 0;
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
                        }
                        
                        _continue = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                        break;
                    }
                    
                    _indent_bottom_limit = _instruction_indent;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _indent_for_options = " + string(_indent_bottom_limit));
                    
                    _new_option = true;
                    _new_option_text = _instruction_content[0];
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     New option \"" + string(_new_option_text) + "\"");
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_SHORTCUT:
                    #region Shortcut
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       _scan_from_text == " + string(_scan_from_text));
                    if (!_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction=" + string(_instruction) + " vs. end=" + string(_end_instruction));
                        if (_instruction == _end_instruction)
                        {
                            _permit_greater_indent = true;
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   Set _permit_greater_indent = " + string(_permit_greater_indent));
                        }
                        
                        _continue = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                        break;
                    }
                    
                    _indent_bottom_limit = _instruction_indent;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _indent_for_options = " + string(_indent_bottom_limit));
                    
                    _new_option = true;
                    _new_option_text = _instruction_content[0];
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       New option \"" + string(_new_option_text) + "\"");
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_SET:
                    #region Set
                    
                    if (_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                        _continue = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                        break;
                    }
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     now executing");
                    __chatterbox_evaluate(_chatterbox, _instruction_content);
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_SUSPEND:
                    #region Suspend
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                    if (_scan_from_text)
                    {
                        _break = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   -> Break ->");
                        break;
                    }
                    else
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_option_end == " + string(_scan_from_option_end));
                        if (_scan_from_option_end)
                        {
                            _text_instruction = _instruction; //Record the instruction position of the text
                            
                            _chatterbox[| __CHATTERBOX.SUSPENDED ] = true;
                            if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox: Suspending");
                            
                            _break = true;
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   -> Break ->");
                            break;
                        }
                    }
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_CUSTOM_ACTION:
                    #region Custom Action
                    
                    if (_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                        _continue = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                        break;
                    }
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     now executing");
                    
                    var _argument_array = array_create(array_length_1d(_instruction_content)-3);
                    array_copy(_argument_array, 0, _instruction_content, 3, array_length_1d(_instruction_content)-3);
                    
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
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   -> BREAK ->");
                        _break = true;
                        break;
                    }
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                    _chatterbox[| __CHATTERBOX.TITLE ] = undefined;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Stop");
                    exit;
                    
                    #endregion
                break;
            }
        
            #region Create a new option from SHORTCUT and OPTION instructions
            
            if (_new_option)
            {
                _new_option = false;
                
                var _scribble = scribble_create(_new_option_text,
                                                _chatterbox[| __CHATTERBOX.OPTION_MIN_LINE_HEIGHT ],
                                                _chatterbox[| __CHATTERBOX.OPTION_MAX_LINE_WIDTH  ],
                                                _chatterbox[| __CHATTERBOX.OPTION_STARTING_COLOUR ],
                                                _chatterbox[| __CHATTERBOX.OPTION_STARTING_FONT   ],
                                                _chatterbox[| __CHATTERBOX.OPTION_STARTING_HALIGN ],
                                                _chatterbox[| __CHATTERBOX.OPTION_DATA_FIELDS     ]);
                
                
                
                var _size = ds_list_size(_option_list);
                for(var _replace_index = 0; _replace_index < _size; _replace_index++)
                {
                    var _array = _option_list[| _replace_index];
                    if (_array[ CHATTERBOX_PROPERTY.SCRIBBLE ] == undefined) break;
                }
                
                if (_replace_index < _size)
                {
                    _array[@ CHATTERBOX_PROPERTY.ITERATION      ] = _iteration;
                    _array[@ CHATTERBOX_PROPERTY.SCRIBBLE       ] = _scribble;
                    _array[@ CHATTERBOX_PROPERTY.__INSTRUCTION0 ] = _text_instruction;
                    _array[@ CHATTERBOX_PROPERTY.__INSTRUCTION1 ] = _instruction;
                }
                else
                {
                    var _new_array = array_create(CHATTERBOX_PROPERTY.__SIZE);
                    _new_array[@ CHATTERBOX_PROPERTY.X              ] = 0;
                    _new_array[@ CHATTERBOX_PROPERTY.Y              ] = 0;
                    _new_array[@ CHATTERBOX_PROPERTY.XY             ] = undefined;
                    _new_array[@ CHATTERBOX_PROPERTY.XSCALE         ] = CHATTERBOX_OPTION_DRAW_DEFAULT_XSCALE;
                    _new_array[@ CHATTERBOX_PROPERTY.YSCALE         ] = CHATTERBOX_OPTION_DRAW_DEFAULT_YSCALE;
                    _new_array[@ CHATTERBOX_PROPERTY.XY_SCALE       ] = undefined;
                    _new_array[@ CHATTERBOX_PROPERTY.ANGLE          ] = CHATTERBOX_OPTION_DRAW_DEFAULT_ANGLE;
                    _new_array[@ CHATTERBOX_PROPERTY.BLEND          ] = CHATTERBOX_OPTION_DRAW_DEFAULT_BLEND;
                    _new_array[@ CHATTERBOX_PROPERTY.ALPHA          ] = CHATTERBOX_OPTION_DRAW_DEFAULT_ALPHA;
                    _new_array[@ CHATTERBOX_PROPERTY.PMA            ] = CHATTERBOX_OPTION_DRAW_DEFAULT_PMA;
                    _new_array[@ CHATTERBOX_PROPERTY.HIGHLIGHTABLE  ] = true;
                    _new_array[@ CHATTERBOX_PROPERTY.SELECTABLE     ] = true;
                    _new_array[@ CHATTERBOX_PROPERTY.__SECTION0     ] = "-- Read-Only Properties --";
                    _new_array[@ CHATTERBOX_PROPERTY.ITERATION      ] = _iteration;
                    _new_array[@ CHATTERBOX_PROPERTY.WIDTH          ] = undefined;
                    _new_array[@ CHATTERBOX_PROPERTY.HEIGHT         ] = undefined;
                    _new_array[@ CHATTERBOX_PROPERTY.SCRIBBLE       ] = _scribble;
                    _new_array[@ CHATTERBOX_PROPERTY.HIGHLIGHTED    ] = undefined;
                    _new_array[@ CHATTERBOX_PROPERTY.__INSTRUCTION0 ] = _text_instruction;
                    _new_array[@ CHATTERBOX_PROPERTY.__INSTRUCTION1 ] = _instruction;
                    ds_list_add(_option_list, _new_array);
                }
            }
            #endregion
        }
        
        if (_break) break;
        
        _instruction++;
    }
    
    #region Create a new option from a TEXT instruction if no option or shortcut was found
    
    var _size = ds_list_size(_option_list);
    for(var _i = 0; _i < _size; _i++)
    {
        var _array = _option_list[| _i ];
        if (_array[ CHATTERBOX_PROPERTY.SCRIBBLE ] != undefined) break;
    }
    
    if (_i >= _size)
    {
        //We haven't found an option that's alive
        var _scribble = scribble_create(_chatterbox[| __CHATTERBOX.SUSPENDED ]? "" : CHATTERBOX_OPTION_DEFAULT_TEXT,
                                        _chatterbox[| __CHATTERBOX.OPTION_MIN_LINE_HEIGHT ],
                                        _chatterbox[| __CHATTERBOX.OPTION_MAX_LINE_WIDTH  ],
                                        _chatterbox[| __CHATTERBOX.OPTION_STARTING_COLOUR ],
                                        _chatterbox[| __CHATTERBOX.OPTION_STARTING_FONT   ],
                                        _chatterbox[| __CHATTERBOX.OPTION_STARTING_HALIGN ],
                                        _chatterbox[| __CHATTERBOX.OPTION_DATA_FIELDS     ]);
        
        if (_size > 0)
        {
            var _array = _option_list[| 0 ]; //Use slot 0
            _array[@ CHATTERBOX_PROPERTY.ITERATION      ] = _iteration;
            _array[@ CHATTERBOX_PROPERTY.SCRIBBLE       ] = _scribble;
            _array[@ CHATTERBOX_PROPERTY.__INSTRUCTION0 ] = _text_instruction;
            _array[@ CHATTERBOX_PROPERTY.__INSTRUCTION1 ] = _text_instruction+1;
        }
        else
        {
            var _new_array = array_create(CHATTERBOX_PROPERTY.__SIZE);
            _new_array[@ CHATTERBOX_PROPERTY.X              ] = 0;
            _new_array[@ CHATTERBOX_PROPERTY.Y              ] = 0;
            _new_array[@ CHATTERBOX_PROPERTY.XY             ] = undefined;
            _new_array[@ CHATTERBOX_PROPERTY.XSCALE         ] = CHATTERBOX_OPTION_DRAW_DEFAULT_XSCALE;
            _new_array[@ CHATTERBOX_PROPERTY.YSCALE         ] = CHATTERBOX_OPTION_DRAW_DEFAULT_YSCALE;
            _new_array[@ CHATTERBOX_PROPERTY.XY_SCALE       ] = undefined;
            _new_array[@ CHATTERBOX_PROPERTY.ANGLE          ] = CHATTERBOX_OPTION_DRAW_DEFAULT_ANGLE;
            _new_array[@ CHATTERBOX_PROPERTY.BLEND          ] = CHATTERBOX_OPTION_DRAW_DEFAULT_BLEND;
            _new_array[@ CHATTERBOX_PROPERTY.ALPHA          ] = CHATTERBOX_OPTION_DRAW_DEFAULT_ALPHA;
            _new_array[@ CHATTERBOX_PROPERTY.PMA            ] = CHATTERBOX_OPTION_DRAW_DEFAULT_PMA;
            _new_array[@ CHATTERBOX_PROPERTY.HIGHLIGHTABLE  ] = true;
            _new_array[@ CHATTERBOX_PROPERTY.SELECTABLE     ] = true;
            _new_array[@ CHATTERBOX_PROPERTY.__SECTION0     ] = "-- Read-Only Properties --";
            _new_array[@ CHATTERBOX_PROPERTY.ITERATION      ] = _iteration;
            _new_array[@ CHATTERBOX_PROPERTY.WIDTH          ] = undefined;
            _new_array[@ CHATTERBOX_PROPERTY.HEIGHT         ] = undefined;
            _new_array[@ CHATTERBOX_PROPERTY.SCRIBBLE       ] = _scribble;
            _new_array[@ CHATTERBOX_PROPERTY.HIGHLIGHTED    ] = undefined;
            _new_array[@ CHATTERBOX_PROPERTY.__INSTRUCTION0 ] = _text_instruction;
            _new_array[@ CHATTERBOX_PROPERTY.__INSTRUCTION1 ] = _text_instruction+1;
            ds_list_add(_option_list, _new_array);
        }
    }
    
    #endregion
    
    #endregion
}