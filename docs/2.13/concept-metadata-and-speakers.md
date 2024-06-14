# Metadata and Speakers

## Metadata

Games with a narrative focus typically have lines of dialogue delivered by specific characters. To indicate a different character is speaking, a game might show a portrait on-screen, it might use a different sound effect for text display, it might cause an animation to play in the game world for the character. A speaker for a line of dialogue is a type of "metadata" - the data itself is the line of dialogue and who's speaking is data attached to the dialogue.

Chatterbox has support for metadata out of the box:

```yarn
Welcome to the frog shop! #FrogShopkeeper
How may I *hop* to your assistance today?
Oh... I... thought this was the dog shop. #Customer
That's what I said, dog shop. Welcome to the dog shop. #FrogShopkeeper #DogMask
```

Metadata can be retrieved from a line of dialogue using the `ChatterboxGetContentMetadata()` function, and options can have metadata attached to them as well. Metadata is returned as an array of strings; if no metadata is attached to a line of dialogue then an empty array is returned. In the example above, the arrays returned by `ChatterboxGetContentMetadata()` would be the following:

```gml
["FrogShopkeeper"]
[]
["Customer"]
["FrogShopkeeper", "DogMask"]
```

Metadata is useful tons of other things, not least identifying individual strings for localisation.

&nbsp;

## Speakers

However, this metadata notion is unfamiliar for writers and can be hard to read. Instead, Chatterbox offers a separate system to metadata that allows for a more convenient syntax to describe who's speaking. It looks like this:

```yarn
FrogShopkeeper: Welcome to the frog shop!
How may I *hop* to your assistance today?
Customer: Oh... I... thought this was the dog shop.
FrogShopkeeper[DogMask]: That's what I said, dog shop. Welcome to the dog shop.
```

?> You can control speaker syntax using [`CHATTERBOX_SPEAKER_DELIMITER`](reference-configuration?id=chatterbox_speaker_delimiter), [`CHATTERBOX_SPEAKER_DATA_START`](reference-configuration?id=chatterbox_speaker_data_start), and [`CHATTERBOX_SPEAKER_DATA_END`](reference-configuration?id=chatterbox_speaker_data_end).

Reading out each line of dialogue using the typical `ChatterboxGetContent()` function will simply return the entire line, including the character speaking the line. To read out dialogue in this formating, you'll need to use the following functions:
- `ChatterboxGetContentSpeech()`
- `ChatterboxGetContentSpeaker()`
- `ChatterboxGetContentSpeakerData()`

Using the example example these functions will return the following strings:

|Speaker            |Speaker Data|Speech                                                    |
|-------------------|------------|----------------------------------------------------------|
|`"FrogShopkeeper"` |`""`        |`"Welcome to the frog shop!"`                             |
|`""`               |`""`        |`"How may I *hop* to your assistance today?"`             |
|`"Customer"`       |`""`        |`"Oh... I... thought this was the dog shop."`             |
|`"FrogShopkeeper"` |`"DogMask"` |`"That's what I said, dog shop. Welcome to the dog shop."`|

For more complex situations you may want to perform additional parsing on the speaker data yourself e.g. splitting up the speaker data into an array. In the example above, `"DogMask"` could be used to control a subimage for a portrait sprite, or perhaps to trigger an animation.