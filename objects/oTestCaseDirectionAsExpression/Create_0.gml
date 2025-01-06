if (CHATTERBOX_ACTION_MODE != 1)
{
    __ChatterboxError("CHATTERBOX_ACTION_MODE should be 1 for this test");
}

ChatterboxLoadFromFile("testcase_direction_as_expression.chatter");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");