function __chatterbox_vm()
{
    content            = [];
    option             = [];
    option_instruction = [];
    
    stopped          = false;
    waiting          = false;
    wait_instruction = undefined;
    entered_shortcut = false;
    leaving_shortcut = false;
    rejected_if      = false;
    
    switch(current_instruction.type)
    {
        case "option":
            current_node = file.find_node(current_instruction.destination);
            current_node.mark_visited();
            current_instruction = current_node.root_instruction;
        break;
        
        case "stop":
            stopped = true;
            if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace("STOP");
            exit;
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
        
        if (!((_instruction.type == "if") || (_instruction.type == "else if")) && variable_struct_exists(_instruction, "condition"))
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
                        __chatterbox_array_add(content, _instruction.text);
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), _instruction.text);
                        
                        if (singleton_text)
                        {
                            if (instanceof(_next) == "__chatterbox_class_instruction")
                            {
                                if ((_next.type != "shortcut") && (_next.type != "option") && (_next.type != "wait"))
                                {
                                    waiting = true;
                                    wait_instruction = _next;
                                    _do_next = false;
                                }
                            }
                        }
                    break;
                    
                    case "wait":
                        waiting = true;
                        wait_instruction = _instruction.next;
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
                            var _file = global.chatterbox_files[? _split.filename];
                            if (instanceof(_file) == "__chatterbox_class_source")
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
                        if ((array_length(content) > 0) && (array_length(option) <= 0))
                        {
                            waiting = true;
                            wait_instruction = _instruction;
                        }
                        else
                        {
                            stopped = true;
                        }
                        
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
                    
                    case "call":
                    case "action":
                        //Shh don't tell anyone but these use the same exact code
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(_instruction.expression);
                        if (__chatterbox_evaluate(local_scope, filename, _instruction.expression) == "<<wait>>")
                        {
                            waiting = true;
                            wait_instruction = _instruction.next;
                            _do_next = false;
                            if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "<<wait>> (returned by function)");
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
            stopped = true;
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