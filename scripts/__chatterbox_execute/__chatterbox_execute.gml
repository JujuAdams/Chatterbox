function __chatterbox_execute()
{
    content            = [];
    option             = [];
    option_instruction = [];
    
    entered_shortcut = false;
    leaving_shortcut = false;
    
    switch(current_instruction.type)
    {
        case "option":
            current_node = file.find_node(current_instruction.destination);
            __chatterbox_mark_visited(current_node);
            current_instruction = current_node.root_instruction;
        break;
        
        case "wait":
            current_instruction = current_node.next;
        break;
    }
    
    __chatterbox_execute_inner(current_instruction);
    if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace("HALT");
}

function __chatterbox_execute_inner(_instruction)
{
    var _do_next = true;
    var _next = variable_struct_get(_instruction, "next");
    
    if (is_string(_instruction.type))
    {
        var _condition_failed = false;
        
        if ((_instruction.type != "if") && variable_struct_exists(_instruction, "condition"))
        {
            if (!__chatterbox_evaluate(filename, _instruction.condition)) _condition_failed = true;
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
                    break;
                    
                    case "wait":
                        __chatterbox_array_add(option, undefined);
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
                            __chatterbox_mark_visited(_next_node);
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
                                __chatterbox_mark_visited(_next_node);
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
                        __chatterbox_evaluate(filename, _instruction.expression);
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(_instruction.expression);
                    break;
                    
                    case "if":
                        if (!__chatterbox_evaluate(filename, _instruction.condition)) _next = variable_struct_get(_instruction, "branch_reject");
                        if (__CHATTERBOX_DEBUG_VM) __chatterbox_trace(_instruction.condition);
                    break;
                    
                    case "end if":
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
            __chatterbox_execute_inner(_next);
        }
        else
        {
            __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "Warning! Instruction found without next node (datatype=", instanceof(_next), ")");
        }
    }
}