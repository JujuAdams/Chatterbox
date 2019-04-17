//  Chatterbox v0.1.2
//  2019/04/15
//  @jujuadams
//  With thanks to Els White

//Initialise Chatterbox
chatterbox_init_start("Yarn");
chatterbox_init_add_findreplace("<<suspend>>", "<<suspend>>\n<<wait>>\n...\n<<wait>>");
chatterbox_init_add_action("suspend", suspend_dialogue);
chatterbox_init_add_json("Test.json");
chatterbox_init_add_json("Test2.json");
chatterbox_init_end();

instance_destroy();
room_goto_next();