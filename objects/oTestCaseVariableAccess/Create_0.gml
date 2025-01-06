//This should throw an error if CHATTERBOX_ERROR_UNDECLARED_VARIABLE is <true>

ChatterboxLoadFromFile("testcase_variable_access.chatter");
box = ChatterboxCreate("testcase_variable_access.chatter");
ChatterboxJump(box, "Start");
show_debug_message(ChatterboxVariableGet("chatterbox_money"));