// Feather disable all

ChatterboxAddFunction("test_func", TestCaseSetterLocalScope);
ChatterboxLoadFromFile("testcase_setter_local_scope.chatter");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");