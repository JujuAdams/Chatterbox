if (CHATTERBOX_DIRECTION_MODE != 2) show_error("CHATTERBOX_DIRECTION_MODE must be set to 2 for this test case\n ", true);

ChatterboxLoadFromFile("testcase_action.yarn");
//Note that <<testcaseAction>> is added as a Chatterbox function in TestCaseActionFunction()
box = ChatterboxCreate();
ChatterboxJump(box, "Start");