chatterbox_load_json("Test.json");
chatterbox_load_json("Test2.json");
chatterbox_load_yarn("Test2.yarn");

//Create a host
box = new chatterbox("Test.json");

//Tell the host to jump to a node
box.goto("Start");