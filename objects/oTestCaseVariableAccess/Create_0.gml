ChatterboxLoadFromFile("testcase_variable_access.yarn");
box = ChatterboxCreate("testcase_variable_access.yarn");
ChatterboxJump(box, "Start");
show_debug_message(ChatterboxVariableGet("yarn_money"));