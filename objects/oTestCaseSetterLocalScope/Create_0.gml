// Feather disable all

ChatterboxAddFunction("test_func", TestCaseSetterLocalScope);
ChatterboxLoadFromFile("testcase_setter_local_scope.yarn");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");