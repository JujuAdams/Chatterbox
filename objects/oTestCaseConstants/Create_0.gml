//This should throw an error if CHATTERBOX_ERROR_UNDECLARED_VARIABLE is <true>

ChatterboxLoadFromFile("testcase_constants.chatter");
box = ChatterboxCreate("testcase_constants.chatter");
ChatterboxJump(box, "Start");

ChatterboxVariableSetConstant("GML_CONSTANT", "this is a constant");

show_debug_message("This string should contain no constants: \"" + ChatterboxVariablesExport() + "\"");
