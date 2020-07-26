function __chatterbox_vm()
{
    content            = [];
    option             = [];
    option_instruction = [];
    
    entered_shortcut    = false;
    leaving_shortcut    = false;
    rejected_if         = false;
    found_first_content = false;
    
    switch(current_instruction.type)
    {
        case "option":
            current_node = file.find_node(current_instruction.destination);
            current_node.mark_visited();
            current_instruction = current_node.root_instruction;
        break;
    }
    
    __chatterbox_vm_inner(current_instruction);
    if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace("HALT");
}

function __chatterbox_vm_inner(_instruction)
{
    var _do_next = true;
    var _next = variable_struct_get(_instruction, "next");
    
    if (is_string(_instruction.type))
    {
        var _condition_failed = false;
        
        if ((_instruction.type != "if") && variable_struct_exists(_instruction, "condition"))
        {
            if (!__chatterbox_evaluate(local_scope, filename, _instruction.condition)) _condition_failed = true;
        }
        
        if (!_condition_failed)
        {
            if (((_instruction.type == "shortcut") || (_instruction.type == "option")) && !leaving_shortcut)
            {
                entered_shortcut = true;
                
                if (_instruction.type == "shortcut")
                {
                    var _branch = variable_struct_get(_instruction, "shortcut_branch");
                    if (_branch == undefined) _branch = variable_struct_get(_instruction, "next");
                
                    __chatterbox_array_add(option, _instruction.text);
                    __chatterbox_array_add(option_instruction, _branch);
                    if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "-> \"", _instruction.text, "\"    ", instanceof(_branch));
                }
                else if (_instruction.type == "option")
                {
                    __chatterbox_array_add(option, _instruction.text);
                    __chatterbox_array_add(option_instruction, _instruction);
                    if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "[\"", _instruction.text, "\" --> ", _instruction.destination, "]");
                }
            }
            else
            {
                if (((_instruction.type != "shortcut") && (_instruction.type != "option")) && leaving_shortcut) leaving_shortcut = false;
            }
            
            if (entered_shortcut)
            {
                if ((_instruction.type != "shortcut") && (_instruction.type != "option"))
                {
                    _do_next = false;
                }
            }
            else
            {
                switch(_instruction.type)
                {
                    case "content":
                        if (found_first_content)
                        {
                            __chatterbox_array_add(option, CHATTERBOX_WAIT_OPTION_TEXT);
                            __chatterbox_array_add(option_instruction, _instruction);
                            _do_next = false;
                        }
                        else
                        {
                            if (singleton_text) found_first_content = true;
                            __chatterbox_array_add(content, _instruction.text);
                            if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), _instruction.text);
                        }
                    break;
                    
                    case "wait":
                        __chatterbox_array_add(option, CHATTERBOX_WAIT_OPTION_TEXT);
                        __chatterbox_array_add(option_instruction, _instruction.next);
                        _do_next = false;
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "<<wait>>");
                    break;
                    
                    case "goto":
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "[goto ", _instruction.destination, "]");
                        
                        var _split = __chatterbox_split_goto(_instruction.destination);
                        if (_split.filename == undefined)
                        {
                            var _next_node = find_node(_split.node);
                            _next_node.mark_visited();
                            _next = _next_node.root_instruction;
                        }
                        else
                        {
                            var _file = variable_struct_get(global.chatterbox_files, _split.filename);
                            if (instanceof(_file) == "__chatterbox_class_file")
                            {
                                file = _file;
                                filename = file.filename;
                                
                                _next_node = find_node(_split.node);
                                _next_node.mark_visited();
                                _next = _next_node.root_instruction;
                            }
                            else
                            {
                                __chatterbox_trace("Error! File \"", _split.filename, "\" not found or not loaded");
                            }
                        }
                    break;
                    
                    case "stop":
                        _do_next = false;
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "<<stop>>");
                    break;
                    
                    case "shortcut end":
                        leaving_shortcut = true;
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "<<shortcut end>>");
                    break;
                    
                    case "set":
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(_instruction.expression);
                        __chatterbox_evaluate(local_scope, filename, _instruction.expression);
                    break;
                    
                    case "action":
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(_instruction.expression);
                        
                        var _method = global.__chatterbox_functions[? _instruction.expression[0]];
                        
                        if (is_method(_method))
                        {
    	                    var _argument_array = array_create(array_length(_instruction.expression)-3);
    	                    array_copy(_argument_array, 0, _instruction.expression, 3, array_length(_instruction.expression)-3);
                            
    	                    var _i = 0;
    	                    repeat(array_length(_argument_array))
    	                    {
    	                        _argument_array[_i] = __chatterbox_resolve_value(local_scope, _argument_array[_i]);
    	                        _i++;
    	                    }
                            
                            with(local_scope)
                            {
                                _method(_argument_array);
                            }
                        }
                        else
                        {
                            __chatterbox_error("Action \"", _instruction.expression[0], "\" not defined with chatterbox_add_action()");
                        }
                    break;
                    
                    case "if":
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace("<<if>> ", _instruction.condition);
                        
                        if (__chatterbox_evaluate(local_scope, filename, _instruction.condition))
                        {
                            rejected_if = false;
                        }
                        else
                        {
                            rejected_if = true;
                            _next = variable_struct_get(_instruction, "branch_reject");
                        }
                    break;
                    
                    case "else":
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace("<<else>>");
                        
                        if (!rejected_if)
                        {
                            _next = variable_struct_get(_instruction, "branch_reject");
                        }
                    break;
                    
                    case "else if":
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace("<<else if>> ", _instruction.condition);
                        
                        if (rejected_if && __chatterbox_evaluate(local_scope, filename, _instruction.condition))
                        {
                            rejected_if = false;
                        }
                        else
                        {
                            _next = variable_struct_get(_instruction, "branch_reject");
                        }
                    break;
                    
                    case "end if":
                        rejected_if = false;
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace("<<end if>>");
                    break;
                    
                    default:
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace("\"", _instruction.type, "\" instruction ignored");
                    break;
                }
            }
        }
    }
    
    if (_do_next)
    {
        if (instanceof(_next) == "__chatterbox_class_instruction")
        {
            __chatterbox_vm_inner(_next);
        }
        else
        {
            __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "Warning! Instruction found without next node (datatype=", instanceof(_next), ")");
        }
    }
}

/// @param string
function __chatterbox_split_goto(_string)
{
    var _pos = string_pos(CHATTERBOX_FILENAME_SEPARATOR, _string);
    if (_pos <= 0)
    {
        return {
            filename : undefined,
            node     : _string,
        };
    }
    else
    {
        return {
            filename : string_copy(_string, 1, _pos-1),
            node     : string_delete(_string, 1, _pos),
        };
    }
}