//  Chatterbox v0.0.7
//  2019/04/15
//  @jujuadams
//  With thanks to Els White
//  
//  
//  For use with Scribble v4.5.1 - https://github.com/GameMakerDiscord/scribble



//Initialise Scribble
scribble_init_start("Fonts");
scribble_init_add_font("fTestA");
scribble_init_add_font("fTestB");
scribble_init_add_spritefont("sSpriteFont", 11);
scribble_init_add_font("fChineseTest");
scribble_init_end();

scribble_add_colour("c_coquelicot", $ff3800);
scribble_add_colour("c_smaragdine", $50c875);
scribble_add_colour("c_xanadu"    , $738678);
scribble_add_colour("c_amaranth"  , $e52b50);

scribble_add_event("sound", play_sound_example);
scribble_add_flag("rumble", 2);

scribble_set_glyph_property("sSpriteFont", "f", SCRIBBLE_GLYPH.SEPARATION, -1, true);
scribble_set_glyph_property("sSpriteFont", "q", SCRIBBLE_GLYPH.SEPARATION, -1, true);



//Initialise Chatterbox
chatterbox_init_start("Yarn");
chatterbox_init_add_action("custom", custom_action_example);
chatterbox_init_add_action("hide", hide_chatterbox);
chatterbox_init_add_json("Test.json");
chatterbox_init_add_json("Test2.json");
chatterbox_init_end();

instance_destroy();
room_goto_next();