if (CHATTERBOX_ACTION_MODE != 2)
{
    __ChatterboxError("CHATTERBOX_ACTION_MODE should be 2 for this test");
}

ChatterboxLoadFromFile("testcase_direction_as_weirdo.chatter");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");