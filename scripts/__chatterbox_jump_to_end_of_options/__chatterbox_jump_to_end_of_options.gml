function __chatterbox_jump_to_end_of_options()
{
    var _next = variable_struct_get(current_instruction, "next_option");
    while(_next != undefined)
    {
        current_instruction = _next;
        _next = variable_struct_get(current_instruction, "next_option");
    }
    
    current_instruction = current_instruction.next;
}