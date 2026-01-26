if (file_exists("localization table.csv"))
{
    show_debug_message(ChatterboxLocalizationGetChars("localization table.csv"));
    show_debug_message(ChatterboxLocalizationGetChars("localization table.csv", true));
    ChatterboxLocalizationLoad("localization table.csv");
}

//Load in some source files
ChatterboxLoadFromFile("testcase_localization.chatter", "test_loc");

ChatterboxAddFunction("TestPopUp", function(_array) { show_message(_array); });

//Create a chatterbox
box = ChatterboxCreate("test_loc");

//Tell the chatterbox to jump to a node
ChatterboxJump(box, "Start");
