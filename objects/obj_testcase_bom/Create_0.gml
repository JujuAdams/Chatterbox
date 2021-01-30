//Load in some source files
chatterbox_load_from_file("Test2.yarn");

//Create a chatterbox
box = chatterbox_create("Test2.yarn");

//Tell the chatterbox to jump to a node
chatterbox_goto(box, "Start");