//  Chatterbox v0.0.3
//  2019/04/15
//  @jujuadams
//  With thanks to Els White
//  
//  
//  For use with Scribble v4.5.1 - https://github.com/GameMakerDiscord/scribble

chatterbox = chatterbox_create();

chatterbox_text_set(chatterbox, false, 0, CHATTERBOX_PROPERTY.XY, 10, 10);

chatterbox_start(chatterbox, "Start", "Test.json");