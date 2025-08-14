//This should throw an error if CHATTERBOX_ERROR_UNDECLARED_VARIABLE is <true>

ChatterboxLoadFromFile("testcase_declare.chatter");
box = ChatterboxCreate("testcase_declare.chatter");
ChatterboxJump(box, "Start");

show_debug_message("$declared_variable = " + string(ChatterboxVariableGet("declared_variable")));