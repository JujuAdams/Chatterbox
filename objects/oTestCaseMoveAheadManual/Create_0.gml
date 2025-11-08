ChatterboxAddFunction("testAction", function()
{
    show_debug_message("Action called successfully");
})

ChatterboxLoadFromFile("testcase_moveahead_manual.chatter");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");

allowMoveAhead = false;