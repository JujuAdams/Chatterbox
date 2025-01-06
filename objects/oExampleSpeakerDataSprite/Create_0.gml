// Feather disable all

//A struct that contains the speaker names, and their possible sprites, with a fallback.
//Written by Scott

actorsList = {
    "Apple": {
        sprites: {
            "Amazed"   : sAppleAmazed,
            "Ashamed"  : sAppleAshamed,
            "Happy"    : sAppleHappy,
            "Fallback" : sAppleBase,
        }
    },
    "Elppa": {
        sprites: {
            "Amazed"   : sElppaAmazed,
            "Ashamed"  : sElppaAshamed,
            "Happy"    : sElppaHappy,
            "Fallback" : sElppaBase,
        }
    },
    "Fallback" : {
        sprites : {
            "Fallback":    sBlank,
        }
    }
};


//Load in some source files
ChatterboxLoadFromFile("example_speakerdata_sprite.chatter");

//Create a chatterbox
box = ChatterboxCreate("example_speakerdata_sprite.chatter");

//Tell the chatterbox to jump to a node
ChatterboxJump(box, "Start");
