//  Chatterbox v0.0.6
//  2019/04/15
//  @jujuadams
//  With thanks to Els White
//  
//  
//  For use with Scribble v4.5.1 - https://github.com/GameMakerDiscord/scribble

chatterbox = chatterbox_create("Test.json");

chatterbox_template_text(     chatterbox, undefined, 250, undefined, "fTestB", undefined, undefined);
chatterbox_template_text_fade(chatterbox, SCRIBBLE_TYPEWRITER_PER_CHARACTER, 0.5, 3,
                                          SCRIBBLE_TYPEWRITER_WHOLE, 0.1, 3);

chatterbox_template_option(     chatterbox, undefined, 250, undefined, "sSpriteFont", undefined, undefined);
chatterbox_template_option_fade(chatterbox, SCRIBBLE_TYPEWRITER_PER_CHARACTER, 0.5, 3,
                                            SCRIBBLE_TYPEWRITER_WHOLE, 0.1, 3);

chatterbox_goto(chatterbox, "Start");