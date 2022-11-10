if (CHATTERBOX_DIRECTION_MODE != 2) show_error("CHATTERBOX_DIRECTION_MODE must be set to 2 for this test case\n ", true);

ChatterboxLoadFromFile("testcase_stop_function.yarn");
//Note that <<testcaseStop>> is added as a Chatterbox function in TestCaseStopFunction()
box = ChatterboxCreate();
ChatterboxJump(box, "Start");
