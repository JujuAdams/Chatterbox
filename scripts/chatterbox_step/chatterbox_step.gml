/// @param json         The Chatterbox data structure to process
/// @param [stepSize]   The step size e.g. a delta time coefficient. Defaults to CHATTERBOX_DEFAULT_STEP_SIZE

var _chatterbox = argument[0];
var _step_size = ((argument_count > 1) && (argument_count[1] != undefined))? argument[1] : CHATTERBOX_DEFAULT_STEP_SIZE;



var _node_title    = _chatterbox[| __CHATTERBOX.TITLE        ];
var _filename      = _chatterbox[| __CHATTERBOX.FILENAME     ];
var _variables_map = _chatterbox[| __CHATTERBOX.VARIABLES    ];
var _text_list     = _chatterbox[| __CHATTERBOX.TEXTS        ];
var _button_list   = _chatterbox[| __CHATTERBOX.BUTTONS      ];
var _executed_map  = _chatterbox[| __CHATTERBOX.EXECUTED_MAP ];

if (_node_title == undefined)
{
    //If the node title is <undefined> then this chatterbox has been stopped
    exit;
}



//Perform a step for all nested Scribble data structures
for(var _i = ds_list_size(_text_list  )-1; _i >= 0; _i--) scribble_step(_text_list[|   _i], _step_size);
for(var _i = ds_list_size(_button_list)-1; _i >= 0; _i--) scribble_step(_button_list[| _i], _step_size);



var _title_map = global.__chatterbox_data[? _filename ];
var _instruction_list = _title_map[? _node_title ];

var _indent = 0;

var _evaluate = false;
if (!_chatterbox[| __CHATTERBOX.INITIALISED])
{
    #region Handle chatterboxes that haven't been initialised yet
    _chatterbox[| __CHATTERBOX.INITIALISED] = true;
    
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
    #region Detect if the player has progressed the dialogue
    
    for(var _i = ds_list_size(_button_list)-1; _i >= 0; _i--)
    {
        if (keyboard_check_pressed(ord(string(_i+1))))
        {
            
            var _button = _button_list[| _i ];
            var _instruction = _button[| __SCRIBBLE.__SIZE ]; //Read the instruction index from a borrowed slot in the Scribble data structure
            
            var _button_array   = _instruction_list[| _instruction];
            var _button_type    = _button_array[ __CHATTERBOX_INSTRUCTION.TYPE    ];
            var _button_indent  = _button_array[ __CHATTERBOX_INSTRUCTION.INDENT  ];
            var _button_content = _button_array[ __CHATTERBOX_INSTRUCTION.CONTENT ];
                
            show_debug_message("Chatterbox: Selected option " + string(_i) + ", \"" + string(_button_content[0]) + "\"");
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
    }
    
    #endregion
}

if (_evaluate)
{
    //Wipe all the old text and buttons
    for(var _i = ds_list_size(_text_list  )-1; _i >= 0; _i--) scribble_destroy(_text_list[|   _i]);
    for(var _i = ds_list_size(_button_list)-1; _i >= 0; _i--) scribble_destroy(_button_list[| _i]);
    ds_list_clear(_text_list);
    ds_list_clear(_button_list);
    
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
        
        if (!_break && !_continue)
        {
            #region Handle branches
            
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
                    
                    #region If-statement evaluation
                    
                    var _resolved_array = array_create(array_length_1d(_instruction_content), pointer_null); //Copy the array
                    
                    var _queue = ds_list_create();
                    ds_list_add(_queue, 1);
                    repeat(9999)
                    {
                        if (ds_list_empty(_queue)) break;
                        
                        var _element_index = _queue[| 0];
                        var _element = _instruction_content[_element_index];
                        
                        if (!is_array(_element))
                        {
                            _resolved_array[_element_index] = _element;
                            ds_list_delete(_queue, 0);
                        }
                        else
                        {
                            #region Check if all elements have been resolved
                            
                            var _fully_resolved = true;
                            var _element_length = array_length_1d(_element);
                            for(var _i = 0; _i < _element_length; _i++)
                            {
                                var _child_index = _element[_i];
                                if (_resolved_array[_child_index] == pointer_null)
                                {
                                    _fully_resolved = false;
                                    ds_list_insert(_queue, 0, _child_index);
                                }
                            }
                            
                            #endregion
                            
                            if (_fully_resolved)
                            {
                                if (_element_length == 1)
                                {
                                    show_debug_message("Chatterbox: WARNING! 1-length evaluation element");
                                    _resolved_array[_element_index] = _element[0];
                                }
                                else if (_element_length == 2)
                                {
                                    #region Resolve unary operators (!variable / -variable)
                                    
                                    var _operator = _resolved_array[_element[0]];
                                    var _value    = _resolved_array[_element[1]];
                                    
                                    if (_operator == "!")
                                    {
                                        _resolved_array[_element_index] = !_value;
                                    }
                                    else if (_operator == "-")
                                    {
                                        _resolved_array[_element_index] = -_value;
                                    }
                                    else
                                    {
                                        show_debug_message("Chatterbox: WARNING! 2-length evaluation element with unrecognised operator: \"" + string(_operator) + "\"");
                                        _resolved_array[_element_index] = undefined;
                                    }
                                    
                                    #endregion
                                }
                                else if (_element_length == 3)
                                {
                                    #region Figure out datatypes and grab variable values
                                    
                                    var _a        = _resolved_array[_element[0]];
                                    var _operator = _resolved_array[_element[1]];
                                    var _b        = _resolved_array[_element[2]];
                                    
                                    var _a_value = __chatterbox_resolve_value(_chatterbox, _a);
                                    var _a_typeof = typeof(_a_value);
                                    var _a_scope = global.__chatterbox_scope;
                                    global.__chatterbox_scope = CHATTERBOX_SCOPE.__INVALID;
                                    var _b_value = __chatterbox_resolve_value(_chatterbox, _b);
                                    var _b_typeof = typeof(_b_value);
                                    
                                    var _pair_typeof = _a_typeof + ":" + _b_typeof;
                                    
                                    #endregion
                                    
                                    #region Resolve binary operators
                                    
                                    var _result = undefined;
                                    var _set = false;
                                    
                                    switch(_operator)
                                    {
                                        case "/": if (_pair_typeof == "real:real") _result = _a_value / _b_value; break;
                                        case "*": if (_pair_typeof == "real:real") _result = _a_value * _b_value; break;
                                        case "-": if (_pair_typeof == "real:real") _result = _a_value - _b_value; break;
                                        case "+": if (!is_undefined(_a_value) && !is_undefined(_b_value)) _result = string(_a_value) + string(_b_value); break;
                                        
                                        case "/=": _set = true; if (_pair_typeof == "real:real") _result = _a_value / _b_value; break;
                                        case "*=": _set = true; if (_pair_typeof == "real:real") _result = _a_value * _b_value; break;
                                        case "-=": _set = true; if (_pair_typeof == "real:real") _result = _a_value - _b_value; break;
                                        case "=":  _set = true;                                  _result =            _b_value; break;
                                        case "+=": _set = true; if (!is_undefined(_a_value) && !is_undefined(_b_value)) _result = string(_a_value) + string(_b_value); break;
                                        
                                        case "||": _result = (_pair_typeof == "real:real")? (_a_value || _b_value) : false; break;
                                        case "&&": _result = (_pair_typeof == "real:real")? (_a_value && _b_value) : false; break;
                                        case ">=": _result = (_pair_typeof == "real:real")? (_a_value >= _b_value) : false; break;
                                        case "<=": _result = (_pair_typeof == "real:real")? (_a_value <= _b_value) : false; break;
                                        case ">":  _result = (_pair_typeof == "real:real")? (_a_value >  _b_value) : false; break;
                                        case "<":  _result = (_pair_typeof == "real:real")? (_a_value <  _b_value) : false; break;
                                        case "!=": _result = (_a_typeof == _b_typeof)?      (_a_value != _b_value) : true;  break;
                                        case "==": _result = (_a_typeof == _b_typeof)?      (_a_value == _b_value) : false; break;
                                    }
                                    
                                    if (_set)
                                    {
                                        switch(_a_scope)
                                        {                   
                                            case CHATTERBOX_SCOPE.INTERNAL:   _variables_map[? _a ] = _result;        break;
                                            case CHATTERBOX_SCOPE.GML_LOCAL:  variable_instance_set(id, _a, _result); break;
                                            case CHATTERBOX_SCOPE.GML_GLOBAL: variable_global_set(_a, _result);       break;
                                        }
                                    }
                                    
                                    _resolved_array[_element_index] = _result;
                                    
                                    #endregion
                                }
                                
                                ds_list_delete(_queue, 0);
                            }
                        }
                    }
                    
                    ds_list_destroy(_queue);
                    
                    #endregion
                    
                    if (!is_bool(_resolved_array[0]) || !is_real(_resolved_array[0]))
                    {
                        show_debug_message("Chatterbox: WARNING! Expression evaluator returned an invalid datatype (" + typeof(_resolved_array[0]) + ")");
                        var _if_state = false;
                    }
                    else
                    {
                        var _if_state = _resolved_array[0];
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
            
            #endregion
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
        
        if (!_break && !_continue)
        {
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
                    if (!_found_text) break;
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _found_text == " + string(_found_text));
                    _new_button = true;
                    _new_button_text = _instruction_content[0];
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       New button \"" + string(_new_button_text) + "\"");
                break;
                
                case __CHATTERBOX_VM_OPTION:
                    if (!_found_text) break;
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _found_text == " + string(_found_text));
                    _new_button = true;
                    _new_button_text = _instruction_content[0];
                    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       New button \"" + string(_new_button_text) + "\"");
                break;
                
                case __CHATTERBOX_VM_SET:
                    if (false)
                    {
                    if (!ds_map_exists(_executed_map, _instruction))
                    {
                        _executed_map[? _instruction ] = true;
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     now executing");
                        
                        #region Evaluation
                    
                        var _result = false;
                        if (array_length_1d(_instruction_content) != 4)
                        {
                            show_error("Chatterbox:\nOnly simple set-statements are supported e.g.\n\"set $variable = 42\"\n ", false);
                        }
                        else if (_instruction_content[2] != "to") && (_instruction_content[2] != "=")
                        {
                            show_error("Chatterbox:\nOnly simple set-statements are supported e.g.\n\"set $variable = 42\"\n ", false);
                        }
                        else
                        {
                            var _variable = _instruction_content[1]; //variable
                            var _value    = __chatterbox_resolve_value(_chatterbox, _instruction_content[3]); //value
                            
                            #region Find the variable's scope based on prefix
                            
                            var _scope = CHATTERBOX_NAKED_VARIABLE_SCOPE;
                            
                            if (string_char_at(_variable, 1) == "$")
                            {
                                _scope = CHATTERBOX_DOLLAR_VARIABLE_SCOPE;
                                _variable = string_delete(_variable, 1, 1);
                            }
                            else if (string_copy(_variable, 1, 2) == "g.")
                            {
                                _scope = CHATTERBOX_SCOPE.GML_GLOBAL;
                                _variable = string_delete(_variable, 1, 2);
                            }
                            else if (string_copy(_variable, 1, 7) == "global.")
                            {
                                _scope = CHATTERBOX_SCOPE.GML_GLOBAL;
                                _variable = string_delete(_variable, 1, 7);
                            }
                            else if (string_copy(_variable, 1, 2) == "l.")
                            {
                                _scope = CHATTERBOX_SCOPE.GML_LOCAL;
                                _variable = string_delete(_variable, 1, 2);
                            }
                            else if (string_copy(_variable, 1, 6) == "local.")
                            {
                                _scope = CHATTERBOX_SCOPE.GML_LOCAL;
                                _variable = string_delete(_variable, 1, 6);
                            }
                            else if (string_copy(_variable, 1, 2) == "i.")
                            {
                                _scope = CHATTERBOX_SCOPE.INTERNAL;
                                _variable = string_delete(_variable, 1, 2);
                            }
                            else if (string_copy(_variable, 1, 9) == "internal.")
                            {
                                _scope = CHATTERBOX_SCOPE.INTERNAL;
                                _variable = string_delete(_variable, 1, 9);
                            }
                            else if (string_copy(_variable, 1, 9) == "visited(\"")
                            {
                                _scope = CHATTERBOX_SCOPE.INTERNAL;
                                
                                if (!CHATTERBOX_VISITED_NO_FILENAME)
                                {
                                    //Make sure this visited() call has a filename attached to it
                                    var _pos = string_pos(CHATTERBOX_VISITED_SEPARATOR, _variable);
                                    if (_pos <= 0) _variable = string_insert(_filename + CHATTERBOX_VISITED_SEPARATOR, _variable, 9);
                                }
                            }
                            
                            #endregion
                            
                            switch(_scope)
                            {                   
                                case CHATTERBOX_SCOPE.INTERNAL:
                                    _variables_map[? _variable ] = _value;
                                    if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox: " + string(_instruction) + ":       set \"" + _instruction_content[1] + "\" to <" + string(_value) + "> as internal variable");
                                break;
                                
                                case CHATTERBOX_SCOPE.GML_LOCAL:
                                    variable_instance_set(id, _variable, _value);
                                    if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox: " + string(_instruction) + ":       set \"" + _instruction_content[1] + "\" to <" + string(_value) + "> as local variable");
                                break;
                                
                                case CHATTERBOX_SCOPE.GML_GLOBAL:
                                    variable_global_set(_variable, _value);
                                    if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox: " + string(_instruction) + ":       set \"" + _instruction_content[1] + "\" to <" + string(_value) + "> as global variable");
                                break;
                            }
                        }
                        
                        #endregion
                    }
                    else
                    {
                        if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     not executed before, ignoring");
                    }
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
        
            #region Create a new button from SHORTCUT and OPTION instructions
            if (_new_button)
            {
                _new_button = false;
                var _button = scribble_create(_new_button_text);
                
                if (ds_list_size(_button_list) <= 0)
                {
                    if (ds_list_size(_text_list) <= 0)
                    {
                        var _y_offset = 0;
                    }
                    else
                    {
                        var _primary_text = _text_list[| 0];
                        var _y_offset = _primary_text[| __SCRIBBLE.TOP ] + _primary_text[| __SCRIBBLE.HEIGHT ] + 15;
                    }
                
                    _button[| __SCRIBBLE.LEFT   ] += 10;
                    _button[| __SCRIBBLE.TOP    ] += _y_offset;
                    _button[| __SCRIBBLE.RIGHT  ] += 10;
                    _button[| __SCRIBBLE.BOTTOM ] += _y_offset;
                    _button[| __SCRIBBLE.__SIZE ]  = _instruction; //Borrow a slot in the Scribble data structure to store the instruction index
                }
                else
                {
                    var _prev_button = _button_list[| ds_list_size(_button_list)-1];
                    var _x_offset = _prev_button[| __SCRIBBLE.LEFT ] - _button[| __SCRIBBLE.LEFT ];
                    var _y_offset = _prev_button[| __SCRIBBLE.TOP ] + _prev_button[| __SCRIBBLE.HEIGHT ] + 5;
                    _button[| __SCRIBBLE.LEFT   ] += _x_offset;
                    _button[| __SCRIBBLE.TOP    ] += _y_offset;
                    _button[| __SCRIBBLE.RIGHT  ] += _x_offset;
                    _button[| __SCRIBBLE.BOTTOM ] += _y_offset;
                    _button[| __SCRIBBLE.__SIZE ]  = _instruction; //Borrow a slot in the Scribble data structure to store the instruction index
                }
                
                ds_list_add(_button_list, _button);
            }
            #endregion
        }
        
        if (_break) break;
        
        _instruction++;
    }
    
    #region Create a new button from a TEXT instruction if no option or shortcut was found
    
    if (ds_list_size(_button_list) <= 0)
    {
        if (ds_list_size(_text_list) <= 0)
        {
            var _y_offset = 0;
        }
        else
        {
            var _primary_text = _text_list[| 0];
            var _y_offset = _primary_text[| __SCRIBBLE.TOP ] + _primary_text[| __SCRIBBLE.HEIGHT ] + 15;
        }
        
        var _button = scribble_create(CHATTERBOX_CONTINUE_TEXT);
        _button[| __SCRIBBLE.LEFT   ] += 10;
        _button[| __SCRIBBLE.TOP    ] += _y_offset;
        _button[| __SCRIBBLE.RIGHT  ] += 10;
        _button[| __SCRIBBLE.BOTTOM ] += _y_offset;
        _button[| __SCRIBBLE.__SIZE ]  = _text_instruction; //Borrow a slot in the Scribble data structure to store the instruction index
        ds_list_add(_button_list, _button);
    }
    
    #endregion
    
    if (__CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Waiting...");
    
    #endregion
}