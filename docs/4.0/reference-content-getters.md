# Content Getters

Functions on this page relate to getting content data from a chatterbox. All functions on this page are prefixed with `ChatterboxGet`.

&nbsp;

## `...Content()`

_Full function name:_ `ChatterboxGetContent(chatterbox, contentIndex)`

_Returns:_ String, content with the given index

|Name          |Datatype                          |Purpose                                         |
|--------------|----------------------------------|------------------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`contentIndex`|integer                           |Content item to return                          |

&nbsp;

## `...AllContentString()`

_Full function name:_ `ChatterboxGetAllContentString(chatterbox, [separator])`

_Returns:_ String, all individual content strings currently available in a chatterbox concatenated together, with a separator substring between each one

|Name         |Datatype                          |Purpose                                                                                            |
|-------------|----------------------------------|---------------------------------------------------------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                                   |
|`[separator]`|string                            |String to use to separate individual content strings. Defaults to a single newline character (`\n`)|

?> This function is intended for use with singleton mode **turned off**. If you use this function in singleton mode then it will only return one content string at a time.

&nbsp;

## `...ContentMetadata()`

_Full function name:_ `ChatterboxGetContentMetadata(chatterbox, contentIndex)`

_Returns:_ Array, the metadata tags associated with the content

|Name          |Datatype                          |Purpose                                         |
|--------------|----------------------------------|------------------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`contentIndex`|integer                           |Content item to return                          |

&nbsp;

## `...ContentCount()`

_Full function name:_ `ChatterboxGetContentCount(chatterbox)`

_Returns:_ Integer, the total number of content strings in the given [chatterbox](concept-chatterboxes)

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

## `...ContentSpeech()`

_Full function name:_ `ChatterboxGetContentSpeech(chatterbox, contentIndex, [default])`

_Returns:_ String

|Name          |Datatype                          |Purpose                                                                                      |
|--------------|----------------------------------|---------------------------------------------------------------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                             |
|`contentIndex`|integer                           |Content item to return the speech for                                                        |
|`[default]`   |any                               |Default value to return if no valid speech is found. If not specified this is an empty string|

This is an optional function that adds additional helpful parsing capabilities to Chatterbox. For `ChatterboxGetContentSpeech()` to work properly, line of text in your ChatterScript file should be formatted like so:

```
Speaker Name: The words that the speaker is saying.
```

In this case, the "speech" part of this string is everything after the colon (`The words that the speaker is saying.`). Any whitespace that leads or follows speech is removed.

&nbsp;

## `...ContentSpeaker()`

_Full function name:_ `ChatterboxGetContentSpeaker(chatterbox, contentIndex, [default])`

_Returns:_ String

|Name          |Datatype                          |Purpose                                                                                      |
|--------------|----------------------------------|---------------------------------------------------------------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                             |
|`contentIndex`|integer                           |Content item to return the speaker for                                                       |
|`[default]`   |any                               |Default value to return if no valid speech is found. If not specified this is an empty string|

This is an optional function that adds additional helpful parsing capabilities to Chatterbox. For `ChatterboxGetContentSpeaker()` to work properly, line of text in your ChatterScript file should be formatted like so:

```
Speaker Name: The words that the speaker is saying.
```

In this case, the "speaker" part of this string is everything before the colon (`Speaker Name`). Any whitespace that leads or follows the speaker name is removed. In the next example, "speaker data" is added to the line of text.

```
Speaker Name[additional speaker data]: The words that the speaker is saying.
```

The speaker part of this string is everything before the speaker data start symbol (see below), which is again `Speaker Name`.

&nbsp;

## `...ContentSpeakerData()`

_Full function name:_ `ChatterboxGetContentSpeakerData(chatterbox, contentIndex, [default])`

_Returns:_ String

|Name          |Datatype                          |Purpose                                                                                      |
|--------------|----------------------------------|---------------------------------------------------------------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                             |
|`contentIndex`|integer                           |Content item to return the speaker data for                                                  |
|`[default]`   |any                               |Default value to return if no valid speech is found. If not specified this is an empty string|

This is an optional function that adds additional helpful parsing capabilities to Chatterbox. For `ChatterboxGetContentSpeakerData()` to work properly, line of text in your ChatterScript file should be formatted like so:

```
Speaker Name[additional speaker data]: The words that the speaker is saying.
```

In this case, the "speaker data" part of this string is everything between `[` and `]` (`additional speaker data`). Any whitespace that leads or follows the speaker data is removed. The symbols used to define where speaker data is stored is controlled by the `CHATTERBOX_SPEAKER_DATA_START` and `CHATTERBOX_SPEAKER_DATA_END` macros. Speaker data must follow the speaker's name and precede the colon that separates the speaker from the speech. If no speaker data is found, the provided default value is returned.

&nbsp;

## `...ContentArray()`

_Full function name:_ `ChatterboxGetContentArray(chatterbox)`

_Returns:_ Array, containing one struct (see below) for each available content string for the given chatterbox

|Name          |Datatype                          |Purpose                                         |
|--------------|----------------------------------|------------------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

The returned array is populated in canonical order: the 0th element of the array is equivalent to `ChatterboxGetContent(chatterbox, 0)` etc. Each struct in the array has this format:

|Member Variable|Purpose                                              |
|---------------|-----------------------------------------------------|
|`.text`        |The text for the content string                      |
|`.metadata`    |An array of metadata tags associated with the content|

?> This function is intended for use with singleton mode **turned off**. If you use this function in singleton mode then it will only return one struct at a time.