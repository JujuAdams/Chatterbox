//Load in some source files
ChatterboxLoadFromFile("Test.yarn");
ChatterboxLoadFromFile("Test2.yarn");

ChatterboxAddFunction("TestFunctionDoNotExecute", function(_array) { show_message(_array); });

//Create a chatterbox
box = ChatterboxCreate("Test.yarn");

//Tell the chatterbox to jump to a node
ChatterboxGoto(box, "Start");