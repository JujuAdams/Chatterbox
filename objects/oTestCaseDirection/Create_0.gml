if (CHATTERBOX_DIRECTION_FUNCTION != TestCaseDirectionFunction)
{
    __ChatterboxError("CHATTERBOX_DIRECTION_FUNCTION must be TestCaseDirectionFunction");
}

ChatterboxLoadFromFile("testcase_direction.yarn");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");