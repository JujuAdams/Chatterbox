delaying = false;

ChatterboxAddFunction("delay", function(_argumentArray)
{
    ChatterboxWait(CHATTERBOX_CURRENT);
    delaying = true;
    show_debug_message("Waiting chatterbox for " + string(_argumentArray[0]) + " frames...");
    time_source_start(time_source_create(time_source_game, _argumentArray[0], time_source_units_frames,
    function(_chatterbox)
    {
        show_debug_message("...continuing chatterbox!");
        delaying = false;
        ChatterboxContinue(_chatterbox);
    },
    [CHATTERBOX_CURRENT]));
});

ChatterboxLoadFromFile("testcase_async_functions.yarn");
box = ChatterboxCreate();
ChatterboxJump(box, "Start");