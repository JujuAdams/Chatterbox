/// @param json         The Chatterbox data structure to process
/// @param [stepSize]   The step size e.g. a delta time coefficient. Defaults to CHATTERBOX_DEFAULT_STEP_SIZE

var _chatterbox = argument[0];
var _step_size = ((argument_count > 1) && (argument_count[1] != undefined))? argument[1] : CHATTERBOX_DEFAULT_STEP_SIZE;



var _node_title  = _chatterbox[| __CHATTERBOX.TITLE    ];
var _filename    = _chatterbox[| __CHATTERBOX.FILENAME ];
var _text_list   = _chatterbox[| __CHATTERBOX.TEXTS    ];
var _button_list = _chatterbox[| __CHATTERBOX.BUTTONS  ];

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

var _indent        = 0;

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
                    
                    var _result = false;
                    if (array_length_1d(_instruction_content) != 4)
                    {
                        show_error("Chatterbox:\nOnly simple if-statements are supported e.g.\n\"if $variable == 42\"\n ", false);
                    }
                    else
                    {
                        var _array = array_create(3);
                        _array[0] = _instruction_content[1]; //A
                        _array[1] = _instruction_content[2]; //comparator
                        _array[2] = _instruction_content[3]; //B
                        
                        var _auto_fail = false;
                        
                        for(var _i = 0; _i < 3; _i++)
                        {
                            if (_i == 0) || (_i == 2)
                            {
                                var _value = _array[_i];
                                
                                //Look for a prefixed ! to indicate negation
                                var _negate = false;
                                if (string_char_at(_value, 1) == "!")
                                {
                                    _negate = true;
                                    _value = string_delete(_value, 1, 1);
                                }
                                
                                if (string_char_at(_value, 1) == "\"") && (string_char_at(_value, string_length(_value)) == "\"")
                                {
                                    //It's a string!
                                    _value = string_copy(_value, 2, string_length(_value)-2);
                                }
                                else
                                {
                                    var _variable = false;
                                    
                                    #region Figure out if this value is a real
                                    
                                    var _hit_number = false;
                                    var _i = string_length(_value);
                                    repeat(string_length(_value))
                                    {
                                        var _character = string_char_at(_value, _i);
                                        if (_character == "0") || (_character == "1") || (_character == "2") || (_character == "3")
                                        || (_character == "4") || (_character == "5") || (_character == "6") || (_character == "7")
                                        || (_character == "8") || (_character == "9") || (_character == ".") || (_character == "-")
                                        {
                                            _hit_number = true;
                                        }
                                        else
                                        {
                                            _variable = true;
                                            break;
                                        }
                                        _i--;
                                    }
                                    
                                    if (!_variable)
                                    {
                                        if (string_count("-", _value) > 1) _variable = true;
                                        if (string_count(".", _value) > 1) _variable = true;
                                        
                                        var _negative_pos = string_pos("-", _value);
                                        if (_negative_pos > 1) _variable = true;
                                        if (string_pos(".", _value) == (1+_negative_pos)) _variable = true;
                                        
                                        if (!_variable) _value = real(_value);
                                    }
                                    
                                    #endregion
                                    
                                    #region Figure out if this value is undefined (or null)
                                    
                                    if (_variable)
                                    {
                                        if (_value == "null") || (_value == "undefined")
                                        {
                                            _value = undefined;
                                            _variable = false;
                                        }
                                    }
                                    
                                    #endregion
                                    
                                    if (_variable)
                                    {
                                        #region Find the variable's scope based on prefix
                                        
                                        var _scope = CHATTERBOX_NAKED_VARIABLE_SCOPE;
                                        
                                        if (string_char_at(_value, 1) == "$")
                                        {
                                            _scope = CHATTERBOX_DOLLAR_VARIABLE_SCOPE;
                                            _value = string_delete(_value, 1, 1);
                                        }
                                        else if (string_copy(_value, 1, 2) == "g.")
                                        {
                                            _scope = CHATTERBOX_SCOPE.GML_GLOBAL;
                                            _value = string_delete(_value, 1, 2);
                                        }
                                        else if (string_copy(_value, 1, 7) == "global.")
                                        {
                                            _scope = CHATTERBOX_SCOPE.GML_GLOBAL;
                                            _value = string_delete(_value, 1, 7);
                                        }
                                        else if (string_copy(_value, 1, 2) == "l.")
                                        {
                                            _scope = CHATTERBOX_SCOPE.GML_LOCAL;
                                            _value = string_delete(_value, 1, 2);
                                        }
                                        else if (string_copy(_value, 1, 6) == "local.")
                                        {
                                            _scope = CHATTERBOX_SCOPE.GML_LOCAL;
                                            _value = string_delete(_value, 1, 6);
                                        }
                                        else if (string_copy(_value, 1, 2) == "i.")
                                        {
                                            _scope = CHATTERBOX_SCOPE.INTERNAL;
                                            _value = string_delete(_value, 1, 2);
                                        }
                                        else if (string_copy(_value, 1, 9) == "internal.")
                                        {
                                            _scope = CHATTERBOX_SCOPE.INTERNAL;
                                            _value = string_delete(_value, 1, 9);
                                        }
                                        
                                        #endregion
                                        
                                        #region Collect variable value depending on scope and check its datatype
                                        
                                        switch(_scope)
                                        {
                                            case CHATTERBOX_SCOPE.IGNORE:
                                                _auto_fail = true;
                                            break;
                                            
                                            case CHATTERBOX_SCOPE.INTERNAL:
                                                if (!ds_map_exists(global.__chatterbox_variable_map, _value))
                                                {
                                                    if (CHATTERBOX_ERROR_ON_MISSING_VARIABLE)
                                                    {
                                                        show_error("Chatterbox:\nInternal variable \"" + _value + "\" doesn't exist!\n ", false);
                                                    }
                                                    else
                                                    {
                                                        show_debug_message("Chatterbox: WARNING! Internal variable \"" + _value + "\" doesn't exist!");
                                                    }
                                                    
                                                    _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
                                                }
                                                else
                                                {
                                                    _value = global.__chatterbox_variable_map[? _value ];
                                                }
                                            break;
                                            
                                            case CHATTERBOX_SCOPE.GML_LOCAL:
                                                if (!variable_instance_exists(id, _value))
                                                {
                                                    if (CHATTERBOX_ERROR_ON_MISSING_VARIABLE)
                                                    {
                                                        show_error("Chatterbox:\nLocal variable \"" + _value + "\" doesn't exist!\n ", false);
                                                    }
                                                    else
                                                    {
                                                        show_debug_message("Chatterbox: WARNING! Local variable \"" + _value + "\" doesn't exist!");
                                                    }
                                                    
                                                    _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
                                                }
                                                else
                                                {
                                                    _value = variable_instance_get(id, _value);
                                                }
                                            break;
                                            
                                            case CHATTERBOX_SCOPE.GML_GLOBAL:
                                                if (!variable_global_exists(_value))
                                                {
                                                    if (CHATTERBOX_ERROR_ON_MISSING_VARIABLE)
                                                    {
                                                        show_error("Chatterbox:\nGlobal variable \"" + _value + "\" doesn't exist!\n ", false);
                                                    }
                                                    else
                                                    {
                                                        show_debug_message("Chatterbox: WARNING! Global variable \"" + _value + "\" doesn't exist!");
                                                    }
                                                    
                                                    _value = CHATTERBOX_DEFAULT_VARIABLE_VALUE;
                                                }
                                                else
                                                {
                                                    _value = variable_global_get(_value);
                                                }
                                            break;
                                        }
                                        
                                        var _typeof = typeof(_value);
                                        if (_typeof == "array") || (_typeof == "ptr") || (_typeof == "null") || (_typeof == "vec3") || (_typeof == "vec4")
                                        {
                                            if (CHATTERBOX_ERROR_ON_INVALID_DATATYPE)
                                            {
                                                show_error("Chatterbox:\nVariable \"" + _value + "\" doesn't exist!\n ", false);
                                            }
                                            else
                                            {
                                                show_debug_message("Chatterbox: WARNING! Variable \"" + _value + "\" has an unsupported datatype (" + _typeof + ")");
                                            }
                                            
                                            _value = string(_value);
                                        }
                                        
                                        if (_typeof == "bool") || (_typeof == "int32") || (_typeof == "int64")
                                        {
                                            _value = real(_value);
                                        }
                                        
                                        #endregion
                                    }
                                }
                                
                                if (_negate)
                                {
                                    if (is_real(_value))
                                    {
                                        _value = !_value;
                                    }
                                    else if (is_string(_value))
                                    {
                                        _value = "";
                                    }
                                }
                                
                                _array[_i] = _value;
                            }
                            else if (_i == 1)
                            {
                                #region Handle comparator variations
                                
                                var _comparator = _array[_i];
                                switch(_comparator)
                                {
                                    //case "and": _comparator = "&&"; break;
                                    //case "&"  : _comparator = "&&"; break;
                                    case "le" : _comparator = "<";  break;
                                    case "gt" : _comparator = ">";  break;
                                    //case "or" : _comparator = "||"; break;
                                    //case "`"  : _comparator = "||"; break;
                                    //case "|"  : _comparator = "||"; break;
                                    case "leq": _comparator = "<="; break;
                                    case "geq": _comparator = ">="; break;
                                    case "eq" : _comparator = "=="; break;
                                    case "is" : _comparator = "=="; break;
                                    case "neq": _comparator = "!="; break;
                                }
                                
                                _array[_i] = _comparator;
                                
                                #endregion
                            }
                        }
                        
                        if (!_auto_fail)
                        {
                            #region Resolve the comparison
                            
                            var _value_a    = _array[1];
                            var _comparator = _array[2];
                            var _value_b    = _array[3];
                            
                            var _less    = false;
                            var _equal   = false;
                            var _greater = false;
                            
                            #region Check if A is less than B
                            
                            if (is_real(_value_a) && is_real(_value_b))
                            {
                                _less = (_value_a < _value_b);
                            }
                            else 
                            {
                                _less = false;
                            }
                            
                            #endregion
                            
                            #region Check if the two values are equal
                            
                            if (is_undefined(_value_a))
                            {
                                _equal = is_undefined(_value_b); //If B isn't <undefined>, the result is always <false>
                            }
                            else if (is_undefined(_value_b))
                            {
                                _equal = false; //A isn't undefined but B is, so the result is <false>
                            }
                            else if (is_string(_value_a) || is_string(_value_b)) //If either A or B is a string, compare the two variables as strings
                            {
                                _equal = (string(_value_a) == string(_value_b));
                            }
                            else //A and B are both reals so let's do a straight comparison
                            {
                                _equal = (_value_a == _value_b);
                            }
                            
                            #endregion
                            
                            #region Check if A is greater than B
                            
                            if (is_real(_value_a) && is_real(_value_b))
                            {
                                _greater = (_value_a > _value_b);
                            }
                            else 
                            {
                                _greater = false;
                            }
                            
                            #endregion
                            
                            switch(_comparator)
                            {
                                case "==": _result =  _equal;             break;
                                case "!=": _result = !_equal;             break;
                                case "<" : _result =  _less;              break;
                                case ">" : _result =  _greater;           break;
                                case "<=": _result =  _equal || _less;    break;
                                case ">=": _result =  _equal || _greater; break;
                            }
                            
                            #endregion
                        }
                        else
                        {
                            _result = false;
                        }
                    }
                    
                    #endregion
                    
                    var _if_state = _result;
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