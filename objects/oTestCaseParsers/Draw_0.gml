// Feather disable all

draw_set_font(fntDefault);

//Iterate over all text and draw it
var _x = 10;
var _y = 10;

if (ChatterboxIsStopped(box))
{
    //If we're stopped then show that
    draw_text(_x, _y, "(Chatterbox stopped)");
}
else
{
    //All the spoken text
    var _i = 0;
    repeat(ChatterboxGetContentCount(box))
    {
        //Split parts of the content with parsers
        var _speaker = ChatterboxGetContentSpeaker(box, _i);
        var _speech  = ChatterboxGetContentSpeech(box, _i);
        
        switch(ChatterboxGetContentSpeakerData(box, _i, 0))
        {
            case 0: _colour = c_yellow; break;
            case 1: _colour = c_red;    break;
            case 2: _colour = c_orange; break;
        }
        
        //Draw speaker name in the correct colour
        draw_set_colour(_colour);
        draw_text(_x, _y, "Name: \""+ _speaker + "\"");
        _y += 40;
        
        //Draw speech
        draw_set_colour(c_white);
        draw_text(_x, _y, "Speech: \""+_speech + "\"");
        _y += 40;
        
        ++_i;
    }
    
    //Bit of spacing...
    _y += 30;
    
    if (ChatterboxIsWaiting(box))
    {
        //If we're in a "waiting" state then prompt the user for basic input
        draw_text(_x, _y, "(Press Space)");
    }
}
