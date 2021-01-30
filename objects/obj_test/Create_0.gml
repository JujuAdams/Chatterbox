//Load in some source files
chatterbox_load_from_file("Test.yarn");
chatterbox_load_from_file("Test2.yarn");

chatterbox_add_function("TestFunctionDoNotExecute", function(_array) { show_message(_array); });

//Create a chatterbox
box = chatterbox_create("Test.yarn");

//Tell the chatterbox to jump to a node
chatterbox_goto(box, "Start");