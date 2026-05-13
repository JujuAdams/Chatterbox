funcInitialize = function()
{
    ChatterboxLoadFromFile("testcase_visited_option.chatter");
    box = ChatterboxCreate();
    ChatterboxJump(box, "Start");
}

funcInitialize();