if (CHATTERBOX_ACTION_MODE != 2) show_error("CHATTERBOX_ACTION_MODE must be set to 2 for this test case\n ", true);

ChatterboxLoadFromFile("testcase_stop_function.chatter");
//Note that <<testcaseStop>> is added as a Chatterbox function in TestCaseStopFunction()
box = ChatterboxCreate();
ChatterboxJump(box, "Start");
