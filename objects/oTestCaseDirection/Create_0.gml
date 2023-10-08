// Feather disable all

if (CHATTERBOX_ACTION_MODE != 0)
{
    __ChatterboxError("CHATTERBOX_ACTION_MODE should be 0 for this test");
}

if (CHATTERBOX_ACTION_FUNCTION != TestCaseDirectionFunction)
{
    __ChatterboxError("CHATTERBOX_ACTION_FUNCTION should be TestCaseDirectionFunction for this test");
}

ChatterboxLoadFromFile("testcase_direction.yarn");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");