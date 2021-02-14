function __ChatterboxVM()
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
    
    if (current_instruction.type == "stop")
    {
        stopped = true;
        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("STOP");
        return undefined;
    }
    
    __ChatterboxVMInner(current_instruction);
    if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("HALT");
}

function __ChatterboxVMInner(_instruction)
{
    var _do_next = true;
    var _next = variable_struct_get(_instruction, "next");
    
    if (is_string(_instruction.type))
    {
        var _condition_failed = false;
        
        if (!((_instruction.type == "if") || (_instruction.type == "else if")) && variable_struct_exists(_instruction, "condition"))
        {
            if (!__ChatterboxEvaluate(local_scope, filename, _instruction.condition, undefined)) _condition_failed = true;
        }
        
        if (!_condition_failed)
        {
            if ((_instruction.type == "shortcut") && !leaving_shortcut)
            {
                entered_shortcut = true;
                
                if (_instruction.type == "shortcut")
                {
                    var _branch = variable_struct_get(_instruction, "shortcut_branch");
                    if (_branch == undefined) _branch = variable_struct_get(_instruction, "next");
                    
                    array_push(option, _instruction.text.evaluate(local_scope, filename));
                    array_push(option_instruction, _branch);
                    if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "-> \"", _instruction.text.raw_string, "\"    ", instanceof(_branch));
                }
            }
            else
            {
                if ((_instruction.type != "shortcut") && leaving_shortcut) leaving_shortcut = false;
            }
            
            if (entered_shortcut)
            {
                if (_instruction.type != "shortcut")
                {
                    _do_next = false;
                }
            }
            else
            {
                switch(_instruction.type)
                {
                    case "content":
                        array_push(content, _instruction.text.evaluate(local_scope, filename));
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), _instruction.text.raw_string);
                        
                        if (singleton_text)
                        {
                            if (instanceof(_next) == "__ChatterboxClassInstruction")
                            {
                                if (((_next.type != "shortcut") || CHATTERBOX_SINGLETON_WAIT_BEFORE_SHORTCUT)
                                &&  (_next.type != "wait")
                                &&  (_next.type != "stop"))
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
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<wait>>");
                    break;
                    
                    case "jump":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "[goto ", _instruction.destination, "]");
                        
                        var _split = __ChatterboxSplitGoto(_instruction.destination);
                        if (_split.filename == undefined)
                        {
                            var _next_node = find_node(_split.node);
                            _next_node.mark_visited();
                            _next = _next_node.root_instruction;
                            current_node = _next_node;
                        }
                        else
                        {
                            var _file = global.chatterbox_files[? _split.filename];
                            if (instanceof(_file) == "__ChatterboxClassSource")
                            {
                                file = _file;
                                filename = file.filename;
                                
                                _next_node = find_node(_split.node);
                                _next_node.mark_visited();
                                _next = _next_node.root_instruction;
                                current_node = _next_node;
                            }
                            else
                            {
                                __ChatterboxTrace("Error! File \"", _split.filename, "\" not found or not loaded");
                            }
                        }
                    break;
                    
                    case "stop":
                        if (CHATTERBOX_WAIT_BEFORE_STOP && (array_length(content) > 0) && (array_length(option) <= 0))
                        {
                            waiting = true;
                            wait_instruction = _instruction;
                        }
                        else
                        {
                            stopped = true;
                        }
                        
                        _do_next = false;
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<stop>>");
                    break;
                    
                    case "shortcut end":
                        leaving_shortcut = true;
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<shortcut end>>");
                    break;
                    
                    case "declare":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(_instruction.expression);
                        __ChatterboxEvaluate(local_scope, filename, _instruction.expression, "declare");
                    break;
                    
                    case "set":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(_instruction.expression);
                        __ChatterboxEvaluate(local_scope, filename, _instruction.expression, "set");
                    break;
                    
                    case "direction":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(_instruction.expression);
                        
                        if (is_method(CHATTERBOX_DIRECTION_FUNCTION))
                        {
                            CHATTERBOX_DIRECTION_FUNCTION(_instruction.text.evaluate(local_scope, filename));
                        }
                        else if (is_numeric(CHATTERBOX_DIRECTION_FUNCTION) && script_exists(CHATTERBOX_DIRECTION_FUNCTION))
                        {
                            script_execute(CHATTERBOX_DIRECTION_FUNCTION, _instruction.text.evaluate(local_scope, filename));
                        }
                        
                        //if (__ChatterboxEvaluate(local_scope, filename, _instruction.expression, false) == "<<wait>>")
                        //{
                        //    waiting = true;
                        //    wait_instruction = _instruction.next;
                        //    _do_next = false;
                        //    if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "<<wait>> (returned by function)");
                        //}
                    break;
                    
                    case "if":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("<<if>> ", _instruction.condition);
                        
                        if (__ChatterboxEvaluate(local_scope, filename, _instruction.condition, undefined))
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
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("<<else>>");
                        
                        if (!rejected_if)
                        {
                            _next = variable_struct_get(_instruction, "branch_reject");
                        }
                    break;
                    
                    case "else if":
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("<<else if>> ", _instruction.condition);
                        
                        if (rejected_if && __ChatterboxEvaluate(local_scope, filename, _instruction.condition, undefined))
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
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("<<end if>>");
                    break;
                    
                    default:
                        if (__CHATTERBOX_DEBUG_VM) __ChatterboxTrace("\"", _instruction.type, "\" instruction ignored");
                    break;
                }
            }
        }
    }
    
    if (_do_next)
    {
        if (instanceof(_next) == "__ChatterboxClassInstruction")
        {
            __ChatterboxVMInner(_next);
        }
        else
        {
            __ChatterboxTrace(__ChatterboxGenerateIndent(_instruction.indent), "Warning! Instruction found without next node (datatype=", instanceof(_next), ")");
            stopped = true;
        }
    }
}

/// @param string
function __ChatterboxSplitGoto(_string)
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