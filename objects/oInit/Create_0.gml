//  Chatterbox v0.1.5
//  2019/09/27
//  @jujuadams
//  With thanks to Els White and Jukio Kallio

//Initialise Chatterbox
chatterbox_init_start("Yarn");
chatterbox_init_add_findreplace("<<suspend>>", "<<suspend>>\n<<wait>>\n...\n<<wait>>");
chatterbox_init_add_action("suspend", suspend_dialogue);
//chatterbox_init_add_json("Test.json");
//chatterbox_init_add_json("Test2.json");
//chatterbox_init_add_yarn("Test2.yarn.txt");
chatterbox_init_add_json("test_story.json");
chatterbox_init_end();

instance_destroy();
room_goto_next();