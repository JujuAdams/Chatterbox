//Load in some source files
ChatterboxLoadFromFile("example.yarn");

ChatterboxAddFunction("TestPopUp", function(_array) { show_message(_array); });

//Create a chatterbox
box = ChatterboxCreate("example.yarn");

//Tell the chatterbox to jump to a node
ChatterboxJump(box, "Start");
