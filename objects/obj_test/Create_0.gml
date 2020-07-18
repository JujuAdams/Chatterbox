//Load in some source files
chatterbox_load("Test.json");
//chatterbox_load("Test2.json");
//chatterbox_load("Test2.yarn");

//Create a chatterbox
box = new chatterbox("Test.json");

//Tell the chatterbox to jump to a node
box.goto("Start");