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
            current_instruction = current_node.root_instruction;
        break;
        
        case "wait":
            current_instruction = current_node.next;
        break;
    }
    
    __chatterbox_execute_inner(current_instruction);
    __chatterbox_trace("HALT");
}

function __chatterbox_execute_inner(_instruction)
{
    var _do_next = true;
    
    if (is_string(_instruction.type))
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
                
                __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "-> \"", _instruction.text, "\"    ", instanceof(_branch));
            }
            else if (_instruction.type == "option")
            {
                __chatterbox_array_add(option, _instruction.text);
                __chatterbox_array_add(option_instruction, _instruction);
                
                __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "[\"", _instruction.text, "\" --> ", _instruction.destination, "]");
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
                    __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "\"", _instruction.text, "\"");
                break;
                
                case "wait":
                    __chatterbox_array_add(option, undefined);
                    __chatterbox_array_add(option_instruction, _instruction.next);
                    _do_next = false;
                
                    __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "<<wait>>");
                break;
                
                case "stop":
                    _do_next = false;
                    
                    __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "<<stop>>");
                break;
                
                case "shortcut end":
                    leaving_shortcut = true;
                    
                    __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "<<shortcut end>>");
                break;
            }
        }
    }
    
    if (_do_next)
    {
        var _next = variable_struct_get(_instruction, "next");
        if (instanceof(_next) == "__chatterbox_class_instruction")
        {
            __chatterbox_execute_inner(_next);
        }
        else
        {
            __chatterbox_trace(__chatterbox_generate_indent(_instruction.indent), "Warning! Instruction found without <next>");
        }
    }
}