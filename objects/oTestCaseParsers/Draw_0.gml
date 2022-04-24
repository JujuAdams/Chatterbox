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
        speaker	= ChatterboxGetSpeaker(box, _i);
        speech		= ChatterboxGetSpeech(box, _i);
        switch		  (ChatterboxGetSpeakerData(box, _i, 0))
        {
            case 0: color = c_yellow; break;
            case 1: color = c_red; break;
            case 2: color = c_orange; break;
        }
        
        //Draw Speaker and apply data
        var c = color;
        draw_text_color(_x, _y, "name: "+speaker, c,c,c,c,1);
        _y += string_height("A");
        
        //Draw Speech
        var c = c_white;
        draw_text_color(_x, _y, "speech: "+speech, c,c,c,c,1);
        _y += string_height("A");
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
