ChatterboxAddFunction("testAction", function()
{
    show_debug_message("Action called successfully");
})

ChatterboxLoadFromFile("testcase_scantonext_manual.chatter");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");

allowScanToNext = false;