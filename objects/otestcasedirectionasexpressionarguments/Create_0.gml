if (CHATTERBOX_DIRECTION_MODE != 1)
{
    __ChatterboxError("CHATTERBOX_DIRECTION_MODE should be 0 for this test");
}

ChatterboxLoadFromFile("testcase_direction_as_expression_arguments.yarn");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");