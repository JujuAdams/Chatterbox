if (CHATTERBOX_DIRECTION_MODE != 2)
{
    __ChatterboxError("CHATTERBOX_DIRECTION_MODE should be 2 for this test");
}

ChatterboxLoadFromFile("testcase_direction_as_weirdo.yarn");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");