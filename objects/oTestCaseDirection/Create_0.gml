if (CHATTERBOX_DIRECTION_MODE != 0)
{
    __ChatterboxError("CHATTERBOX_DIRECTION_MODE should be 0 for this test");
}

if (CHATTERBOX_DIRECTION_FUNCTION != TestCaseDirectionFunction)
{
    __ChatterboxError("CHATTERBOX_DIRECTION_FUNCTION should be TestCaseDirectionFunction for this test");
}

ChatterboxLoadFromFile("testcase_direction.yarn");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");