/// Selects an option presented by Chatterbox
/// 
/// Chatterbox will output a series of options. This script selects one of those options.
/// Once an option is selected, the script will then process dialogue accordingly. Any text
/// that's outputted can be picked up by chatterbox_get_string() and chatterbox_get_string_count().
///
/// @param chatterboxHost
/// @param optionIndex

var _chatterbox     = argument0;
var _selected_index = argument1;

var _node_title     = _chatterbox[__CHATTERBOX_HOST.TITLE         ];
var _filename       = _chatterbox[__CHATTERBOX_HOST.FILENAME      ];
var _child_array    = _chatterbox[__CHATTERBOX_HOST.CHILDREN      ];
var _singleton_text = _chatterbox[__CHATTERBOX_HOST.SINGLETON_TEXT];

if (_node_title == undefined)
{
    //If the node title is <undefined> then this chatterbox has been stopped
    exit;
}

//VM state
var _key                     = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
var _start_indent            = 0;
var _indent_bottom_limit     = 0;
var _text_instruction        = 0;
var _start_instruction       = global.__chatterbox_goto[? _key ];
var _end_instruction         = -1;
var _post_text               = false;
var _scan_from_last_wait     = false;
var _at_scan_end_instruction = false;
var _if_state                = true;
var _permit_greater_indent   = false;

if (is_real(_selected_index))
{
    //Scan through all children to find the selected option
    var _array = undefined;
    var _count = 0;
    var _size = array_length_1d(_child_array);
    for(var _i = 0; _i < _size; _i++)
    {
        var _array = _child_array[_i];
        if (_array[__CHATTERBOX_CHILD.TYPE] == __CHATTERBOX_CHILD_TYPE.OPTION)
        {
            if (_count == _selected_index) break;
            _count++;
        }
    }
    
    //If we can't find the selected option, bail
    if ((_i >= _size) || !is_array(_array))
    {
        if (CHATTERBOX_DEBUG) __chatterbox_trace("Selected option (", _selected_index, ") could not be found. Total number of options is ", _count);
        return false;
    }
    
    var _start_instruction = _array[__CHATTERBOX_CHILD.INSTRUCTION_START];
    var _end_instruction   = _array[__CHATTERBOX_CHILD.INSTRUCTION_END  ];
    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("start instruction = ", _start_instruction);
    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("end instruction = ", _end_instruction);
    
    _scan_from_last_wait = true;
    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("_scan_from_last_wait=", _scan_from_last_wait);
    
    var _array = global.__chatterbox_vm[| _start_instruction ];
    if (!is_array(_array))
    {
        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("Non-array: \"", _array, "\"");
    }
    else
    {
        _start_indent = _array[__CHATTERBOX_INSTRUCTION.INDENT];
        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("start indent = ", _start_indent);
        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("Starting scan from option index=", _selected_index, ", \"", _array[__CHATTERBOX_INSTRUCTION.CONTENT], "\"");
    }
    
    _child_array = []; //Wipe all children
    _chatterbox[@ __CHATTERBOX_HOST.CHILDREN] = _child_array;
    
    var _instruction = _start_instruction;
    var _indent      = _start_indent;
    
    var _break = false;
    repeat(9999)
    {
        var _continue = false;
            _at_scan_end_instruction = false;
        
        var _instruction_array = global.__chatterbox_vm[| _instruction];
        if (!is_array(_instruction_array))
        {
            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("Non-array: \"", _instruction_array, "\"");
            _instruction++;
            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("<- CONTINUE <-");
            continue;
        }
        
        var _instruction_type    = _instruction_array[__CHATTERBOX_INSTRUCTION.TYPE   ];
        var _instruction_indent  = _instruction_array[__CHATTERBOX_INSTRUCTION.INDENT ];
        var _instruction_content = _instruction_array[__CHATTERBOX_INSTRUCTION.CONTENT];
        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("inst", string_format(_instruction, 5, 0), "  >> ", string_format(_instruction_indent, 2, 0), "    ", _instruction_type, "  ", _instruction_content);
        
        if (_scan_from_last_wait)
        {
            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _scan_from_last_wait == ", _scan_from_last_wait);
            
            if (_instruction == _end_instruction)
            {
                if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    ", _instruction, " == ", _end_instruction, ", scan end");
                _indent                  = _instruction_indent;
                _scan_from_last_wait     = false;
                _at_scan_end_instruction = true;
                if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    indent = ", _indent);
                if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _scan_from_last_wait = ", _scan_from_last_wait);
                if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _at_scan_end_instruction = ", _at_scan_end_instruction);
            }
            else if (_instruction > _end_instruction)
            {
                __chatterbox_error("VM instruction overstepped bounds!\n ", true);
                _instruction = _end_instruction;
                continue;
            }
        }
        
        #region Identation behaviours
        
        if (_instruction_indent < _indent)
        {
            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    indent ", _instruction_indent, " < indent ", _indent);
            if (!_post_text)
            {
                _indent = _instruction_indent;
                if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    indent = ", _indent);
            }
            else if (_instruction_indent < _indent_bottom_limit)
            {
                if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    instruction indent ", _instruction_indent, " < _indent_bottom_limit ", _indent_bottom_limit);
                _break = true;
                if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    -> BREAK ->");
            }
        }
        else if (_instruction_indent > _indent)
        {
            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    instruction indent ", _instruction_indent, " > indent " , _indent);
            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _permit_greater_indent=", _permit_greater_indent);
            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    indent difference=", _instruction_indent - _indent);
            if (_permit_greater_indent && ((_instruction_indent - _indent) <= CHATTERBOX_INDENT_UNIT_SIZE))
            {
                _indent = _instruction_indent;
                if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    indent = ", _indent);
            }
            else
            {
                _continue = true;
                if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    <- CONTINUE <-");
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
                            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _if_state == " + string(_if_state));
                            _continue = true;
                            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    <- CONTINUE <-");
                            break;
                        }
                    }
                    
                    //Only evaluate the elseif-statement if we failed the previous check
                    if (_instruction_type == __CHATTERBOX_VM_ELSEIF)
                    {
                        if (_if_state)
                        {
                            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _if_state == ", _if_state);
                            _if_state = false;
                            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _if_state = ", _if_state);
                            _continue = true;
                            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    <- CONTINUE <-");
                            break;
                        }
                    }
                    
                    var _result = __chatterbox_evaluate(_chatterbox, _instruction_content);
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    Evaluator returned \"" + string(_result) + "\" (" + typeof(_result) + ")");
                    
                    if (!is_bool(_result) && !is_real(_result))
                    {
                        __chatterbox_trace("WARNING! Expression evaluator returned an invalid datatype (" + typeof(_result) + ")");
                        var _if_state = false;
                    }
                    else
                    {
                        var _if_state = _result;
                    }
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _if_state = " + string(_if_state));
                    
                    if (_if_state)
                    {
                        _permit_greater_indent = true;
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _permit_greater_indent = " + string(_permit_greater_indent));
                    }
                break;
                
                case __CHATTERBOX_VM_ELSE:
                    _if_state = !_if_state;
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    Invert _if_state = " + string(_if_state));
                    
                    if (_if_state)
                    {
                        _permit_greater_indent = true;
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _permit_greater_indent = " + string(_permit_greater_indent));
                    }
                break;
                
                case __CHATTERBOX_VM_ENDIF:
                    _if_state = true;
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _if_state = " + string(_if_state));
                break;
            }
            
        }
        
        if (!_break && !_continue)
        {
            //If we're inside a branch that has been evaluated as <false> then keep skipping until we close the branch
            if (!_if_state)
            {
                if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _if_state == " + string(_if_state));
                _continue = true;
                if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    <- CONTINUE <-");
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
                    
                    if (_post_text)
                    {
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _post_text == " + string(_post_text));
                        _break = true;
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    -> BREAK ->");
                        break;
                    }
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_TEXT:
                    #region Text
                    
                    if (_scan_from_last_wait)
                    {
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _scan_from_last_wait == " + string(_scan_from_last_wait));
                        _continue = true;
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    <- CONTINUE <-");
                        break;
                    }
                    
                    if (_post_text && _singleton_text)
                    {
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _post_text == " + string(_post_text));
                        _break = true;
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    -> BREAK ->");
                        break;
                    }
                    
                    _post_text = true;
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _post_text = " + string(_post_text));
                    
                    var _new_array = array_create(__CHATTERBOX_CHILD.__SIZE);
                    _new_array[@ __CHATTERBOX_CHILD.STRING           ] = _instruction_content[0];
                    _new_array[@ __CHATTERBOX_CHILD.TYPE             ] = __CHATTERBOX_CHILD_TYPE.BODY;
                    _new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_START] = undefined;
                    _new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_END  ] = undefined;
                    _child_array[@ array_length_1d(_child_array) ] = _new_array;
                    
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    Added body string \"", _instruction_content[0], "\"");
                    
                    var _text_instruction = _instruction; //Record the instruction position of the text
                    
                    _indent_bottom_limit = _instruction_indent;
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _indent_for_options = " + string(_indent_bottom_limit));
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_REDIRECT:
                    #region Redirect
                    
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _post_text == " + string(_post_text));
                    if (_post_text)
                    {
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    -> BREAK ->");
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
                        
                        _chatterbox[@ __CHATTERBOX_HOST.TITLE    ] = _node_title;
                        _chatterbox[@ __CHATTERBOX_HOST.FILENAME ] = _filename;
                        
                        var _key = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
                        CHATTERBOX_VARIABLES_MAP[? "visited(" + _key + ")" ] = true;
                        if (CHATTERBOX_DEBUG) __chatterbox_trace("  \"visited(" + _key + ")\" to <true>");
                        
                        if (!ds_map_exists(global.__chatterbox_goto, _key))
                        {
                            if (!ds_map_exists(global.__chatterbox_file_data, _filename))
                            {
                                __chatterbox_error("File \"" + string(_filename) + "\" not initialised.\n ", true);
                                exit;
                            }
                            else
                            {
                                __chatterbox_error("Node title \"" + string(_node_title) + "\" not found in file \"" + string(_filename) + "\".\n ", true);
                                exit;
                            }
                        }
                        
                        //Partially reset state
                        var _text_instruction        = -1;
                        var _instruction             = global.__chatterbox_goto[? _key ]-1;
                        var _end_instruction         = -1;
                        var _if_state                = true;
                        var _permit_greater_indent   = false;
                        var _at_scan_end_instruction = false;
                        
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("Jumping to " + string(_key) + ", instruction = " + string(_instruction) + " (inc. -1 offset)" );
                        
                        var _instruction_array   = global.__chatterbox_vm[| _instruction+1];
                            _indent              = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
                            _indent_bottom_limit = 0;
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("indent = " + string(_indent));
                        
                        _continue = true;
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    <- CONTINUE <-");
                        break;
                    }
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_OPTION:
                    #region Option
                    
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _post_text == " + string(_post_text));
                    if (!_post_text)
                    {
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _at_scan_end_instruction == " + string(_at_scan_end_instruction));
                        if (_at_scan_end_instruction)
                        {
                            _node_title = _instruction_content[1];
                            _chatterbox[@ __CHATTERBOX_HOST.TITLE] = _node_title;
                            
                            var _key = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
                            CHATTERBOX_VARIABLES_MAP[? "visited(" + _key + ")" ] = true;
                            if (CHATTERBOX_DEBUG) __chatterbox_trace("  \"visited(" + _key + ")\" to <true>");
                        
                            if (!ds_map_exists(global.__chatterbox_goto, _key))
                            {
                                if (!ds_map_exists(global.__chatterbox_file_data, _filename))
                                {
                                    __chatterbox_error("File \"" + string(_filename) + "\" not initialised.\n ", true);
                                    exit;
                                }
                                else
                                {
                                    __chatterbox_error("Node title \"" + string(_node_title) + "\" not found in file \"" + string(_filename) + "\".\n ", true);
                                    exit;
                                }
                            }
                            
                            //Partially reset state
                            var _text_instruction        = -1;
                            var _instruction             = global.__chatterbox_goto[? _key]-1;
                            var _end_instruction         = -1;
                            var _if_state                = true;
                            var _permit_greater_indent   = false;
                            var _at_scan_end_instruction = false;
                            
                            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    >>> JUMP >>>  " + string(_key) + ", instruction = " + string(_instruction) + " (inc. -1 offset)");
                            
                            var _instruction_array   = global.__chatterbox_vm[| _instruction+1];
                                _indent              = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
                                _indent_bottom_limit = 0;
                            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("indent = " + string(_indent));
                        }
                        
                        _continue = true;
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    <- CONTINUE <-");
                        break;
                    }
                    
                    _indent_bottom_limit = _instruction_indent;
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _indent_for_options = " + string(_indent_bottom_limit));
                    
                    _new_option = true;
                    _new_option_text = _instruction_content[0];
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    New option \"" + string(_new_option_text) + "\"");
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_SHORTCUT:
                    #region Shortcut
                    
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _post_text == " + string(_post_text));
                    if (!_post_text)
                    {
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    instruction=" + string(_instruction) + " vs. end=" + string(_end_instruction));
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    indent=" + string(_indent) + " >= start=" + string(_start_indent));
                        if ((_instruction == _end_instruction) && (_indent >= _start_indent))
                        {
                            _permit_greater_indent = true;
                            if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _permit_greater_indent = " + string(_permit_greater_indent));
                        }
                        
                        _continue = true;
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    <- CONTINUE <-");
                        break;
                    }
                    
                    _indent_bottom_limit = _instruction_indent;
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _indent_for_options = " + string(_indent_bottom_limit));
                    
                    _new_option = true;
                    _new_option_text = _instruction_content[0];
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    New option \"" + string(_new_option_text) + "\"");
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_SET:
                    #region Set
                    
                    if (_post_text)
                    {
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _post_text == " + string(_post_text));
                        _continue = true;
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    <- CONTINUE <-");
                        break;
                    }
                    
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    now executing");
                    __chatterbox_evaluate(_chatterbox, _instruction_content);
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_CUSTOM_ACTION:
                    #region Custom Action
                    
                    if (_post_text)
                    {
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _post_text == " + string(_post_text));
                        _continue = true;
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    <- CONTINUE <-");
                        break;
                    }
                    
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    now executing");
                    
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
                    
                    if (_post_text)
                    {
                        if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    -> BREAK ->");
                        _break = true;
                        break;
                    }
                    
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    _post_text == " + string(_post_text));
                    _chatterbox[@ __CHATTERBOX_HOST.TITLE ] = undefined;
                    if (CHATTERBOX_DEBUG_SELECT) __chatterbox_trace("                    !! STOP !!");
                    exit;
                    
                    #endregion
                break;
            }
        
            #region Create a new option from SHORTCUT and OPTION instructions
            
            if (_new_option)
            {
                _new_option = false;
                
                var _new_array = array_create(__CHATTERBOX_CHILD.__SIZE);
                _child_array[@ array_length_1d(_child_array)] = _new_array;
                _new_array[@ __CHATTERBOX_CHILD.STRING           ] = _new_option_text;
                _new_array[@ __CHATTERBOX_CHILD.TYPE             ] = __CHATTERBOX_CHILD_TYPE.OPTION;
                _new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_START] = _text_instruction;
                _new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_END  ] = _instruction;
            }
            #endregion
        }
        
        if (_break) break;
        
        _instruction++;
    }
    
    if (CHATTERBOX_OPTION_FALLBACK_ENABLE)
    {
        #region Create a new option from a TEXT instruction if no option or shortcut was found
        
        //Scan through all children to find the selected option
        var _size = array_length_1d(_child_array);
        for(var _i = 0; _i < _size; _i++)
        {
            var _array = _child_array[ _i ];
            if (_array[ __CHATTERBOX_CHILD.TYPE ] == __CHATTERBOX_CHILD_TYPE.OPTION) break;
        }
        
        if (_i >= _size)
        {
            //We haven't found an option so we should create one!
            var _new_array = array_create(__CHATTERBOX_CHILD.__SIZE);
            _new_array[@ __CHATTERBOX_CHILD.STRING           ] = CHATTERBOX_OPTION_FALLBACK_TEXT;
            _new_array[@ __CHATTERBOX_CHILD.TYPE             ] = __CHATTERBOX_CHILD_TYPE.OPTION;
            _new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_START] = _text_instruction;
            _new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_END  ] = _instruction;
            _child_array[@ array_length_1d(_child_array)] = _new_array;
        }
        
        #endregion
    }
    
    return true;
}

return false;