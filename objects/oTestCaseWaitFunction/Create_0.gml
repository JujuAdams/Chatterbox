if (CHATTERBOX_ACTION_MODE != 2) show_error("CHATTERBOX_ACTION_MODE must be set to 2 for this test case\n ", true);

ChatterboxLoadFromFile("testcase_wait_function.yarn");
//Note that <<testcaseWaitReturn>> is added as a Chatterbox function in TestCaseWaitFunctionReturn()
//Note that <<testcaseWait>> is added as a Chatterbox function in TestCaseWaitFunction()
box = ChatterboxCreate(undefined, false);
ChatterboxJump(box, "Start");
