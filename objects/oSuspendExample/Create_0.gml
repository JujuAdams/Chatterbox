chatterbox_init_start("Yarn");
chatterbox_init_add_findreplace("<<suspend>>", "<<suspend>>\n<<wait>>\n...\n<<wait>>");
chatterbox_init_add_action("suspend", suspend_dialogue);
chatterbox_init_add_json("Test.json");
chatterbox_init_add_json("Test2.json");
chatterbox_init_add_yarn("Test2.yarn");
chatterbox_init_end();



chatterbox = chatterbox_create_host("Test.json");
chatterbox_goto(chatterbox, "Start");

suspend = false;