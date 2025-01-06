if (CHATTERBOX_ACTION_MODE != 1)
{
    __ChatterboxError("CHATTERBOX_ACTION_MODE should be 0 for this test");
}

ChatterboxLoadFromFile("testcase_direction_as_expression_arguments.chatter");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");