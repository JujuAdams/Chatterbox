//This should throw an error if CHATTERBOX_ERROR_UNDECLARED_VARIABLE is <true>

ChatterboxLoadFromFile("testcase_variable_access.yarn");
box = ChatterboxCreate("testcase_variable_access.yarn");
ChatterboxJump(box, "Start");
show_debug_message(ChatterboxVariableGet("yarn_money"));