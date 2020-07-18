function __chatterbox_execute()
{
    content            = [];
    option             = [];
    option_instruction = [];
    
    switch(current_instruction.type)
    {
        case "goto":
        case "option":
            return goto(current_instruction.destination);
        break;
        
        case "wait":
            current_instruction = current_instruction.next;
        break;
    }
    
    global.__chatterbox_in_option = false;
    __chatterbox_execute_inner();
}

function __chatterbox_execute_inner()
{
    __chatterbox_trace(current_instruction.type, " l", current_instruction.line, ":    ", variable_struct_get(current_instruction, "text"));
    
    switch(current_instruction.type)
    {
        case "shortcut":
        case "option":
            var _write_option = true;
            
            if (!global.__chatterbox_in_option)
            {
                if (variable_struct_exists(current_instruction, "previous_option"))
                {
                    _write_option = false;
                    
                    current_instruction = current_instruction.next_option;
                    __chatterbox_execute_inner();
                }
                else
                {
                    global.__chatterbox_in_option = true;
                }
            }
            
            if (_write_option)
            {
                __chatterbox_array_add(option, current_instruction.text);
                __chatterbox_array_add(option_instruction, current_instruction);
                
                if (variable_struct_exists(current_instruction, "next_option"))
                {
                    current_instruction = current_instruction.next_option;
                    __chatterbox_execute_inner();
                }
            }
        break;
        
        case "content":
            __chatterbox_array_add(content, current_instruction.text);
            current_instruction = current_instruction.next;
            __chatterbox_execute_inner();
        break;
        
        case "wait":
            __chatterbox_array_add(option, undefined);
            __chatterbox_array_add(option_instruction, current_instruction);
        break;
        
        case "stop":
        break;
        
        case "set":
        case "if":
        case "else":
        case "else if":
        case "end if":
            current_instruction = current_instruction.next;
            __chatterbox_execute_inner();
        break;
        
        case "end options":
            if (!global.__chatterbox_in_option)
            {
                current_instruction = current_instruction.next;
                __chatterbox_execute_inner();
            }
        break;
        
        case "null":
            current_instruction = current_instruction.next;
            __chatterbox_execute_inner();
        break;
    }
}