draw_set_font(fntDefault);
draw_set_halign(fa_center);

//Iterate over all text and draw it
var _x = room_width/2;
var _y = room_height/2 + 200;

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
        var _speaker = ChatterboxGetContentSpeaker(box, _i); //Returns Name ex:  NPC[Happy]:  Returns NPC: 
        var _speakerData = ChatterboxGetContentSpeakerData(box, _i); // Returns Data After name ex NPC[Happy]: returns Happy
        var _currentActor = actorsList[$ _speaker] ?? actorsList[$ "Fallback"]; //Returns the Actor struct for the specified speaker, with the Fallback.
        var _speakerSprite = _currentActor.sprites[$ _speakerData]; //Gets the sprite from the Actor struct.
        if (_speakerSprite == undefined) _speakerSprite = _currentActor.sprites.Fallback; //Use the fallback sprite if needed.
        var _currentSprite = _speakerSprite; // References the current actor then references which sprite should be used
        var _string = ChatterboxGetContentSpeech(box, _i);
        draw_text(_x, _y, _speaker);
        _y += 40;
        draw_text(_x, _y, _string);
        draw_sprite(_currentSprite, 0, room_width/2, room_height/2);
        _y += string_height(_string);
        ++_i;
    }
    
    //Bit of spacing...
    _y += 40;

    if (ChatterboxIsWaiting(box))
    {
        //If we're in a "waiting" state then prompt the user for basic input
        draw_text(_x, _y, "(Press Space)");
    }
    else
    {
        //All the options
        var _i = 0;
        repeat(ChatterboxGetOptionCount(box))
        {
            var _string = ChatterboxGetOption(box, _i);
            draw_text(_x, _y, string(_i+1) + ") " + _string);
            _y += string_height(_string);
            ++_i;
        }
    }
}