if (file_exists("localization table.csv"))
{
    ChatterboxLocalizationLoad("localization table.csv");
}

//Load in some source files
ChatterboxLoadFromFile("testcase_localization.yarn");

ChatterboxAddFunction("TestPopUp", function(_array) { show_message(_array); });

//Create a chatterbox
box = ChatterboxCreate("testcase_localization.yarn");

//Tell the chatterbox to jump to a node
ChatterboxJump(box, "Start");
