chatterbox_load("Test.json");
chatterbox_load("Test2.json");
chatterbox_load("Test2.yarn");

//Create a host
box = new chatterbox("Test.json");

//Tell the host to jump to a node
box.goto("Start");