# Chatterboxes Reference

Functions on this page relate to chatterboxes, the basic machines that use source files as input and output strings of text that you can display in your game. Most functions on this page are prefixed with `Chatterbox`.

&nbsp;

### `ChatterboxCreate()`

_Full function name:_ `ChatterboxCreate([filename], [singletonText]), [localScope])`

_Returns:_ A new [chatterbox](concept-chatterboxes)

|Name             |Datatype       |Purpose                                                                                                                                                                                                                                                                          |
|-----------------|---------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`[filename]`     |string         |[Source file](concept-source-files) to target. If not specified, the default [source file](concept-source-files) will be used (the first [source file](concept-source-files) that was [loaded](reference-configuration#chatterboxloadfromfilefilename-aliasname) into Chatterbox)|
|`[singletonText]`|boolean        |Whether content is revealed one line at a time (see below). If not specified, [`CHATTERBOX_DEFAULT_SINGLETON`](reference-configuration#__chatterboxconfig) is used instead                                                                                                       |
|`[localScope]`   |instance/struct|Scope to execute Yarn function calls in                                                                                                                                                                                                                                          |

If `singletonText` is set to `true` then dialogue will be outputted one line at a time. This is typical behaviour for RPGs like Pokémon or Final Fantasy where characters talk one at a time. Only one piece of dialogue will be shown at a time.

However, if `singletonText` is set to `false` then dialogue will be outputted multiple lines at a time. More modern narrative games, especially those by Inkle or Failbetter, tend to show larger blocks of text. Content will be stacked up until Chatterbox reaches a command that requires user input: a shortcut, an option, or a `<<stop>>` or `<<wait>>` command.

&nbsp;

### `IsChatterbox(value)`

_Full function name:_ `IsChatterbox(value)`

_Returns:_ Boolean, whether the given value is a [chatterbox](concept-chatterboxes)

|Name   |Datatype|Purpose           |
|-------|--------|------------------|
|`value`|any     |The value to check|

&nbsp;

### `...GetVisited()`

_Full function name:_ `ChatterboxGetVisited(nodeTitle, filename)`

_Returns:_ Boolean, whether the given node has been visited

|Name      |Datatype|Purpose                                                 |
|----------|--------|--------------------------------------------------------|
|`nodeTile`|string  |Name of the node to check                               |
|`filename`|string  |Name of the [source file](concept-source-files) to check|

&nbsp;

### `...GetContent()`

_Full function name:_ `ChatterboxGetContent(chatterbox, contentIndex)`

_Returns:_ String, content with the given index

|Name          |Datatype                          |Purpose                                         |
|--------------|----------------------------------|------------------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`contentIndex`|integer                           |Content item to return                          |

&nbsp;

### `...GetAllContentString()`

_Full function name:_ `ChatterboxGetAllContentString(chatterbox, [separator])`

_Returns:_ String, all individual content strings currently available in a chatterbox concatenated together, with a separator substring between each one

|Name         |Datatype                          |Purpose                                                                                            |
|-------------|----------------------------------|---------------------------------------------------------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                                   |
|`[separator]`|string                            |String to use to separate individual content strings. Defaults to a single newline character (`\n`)|

?> This function is intended for use with singleton mode **turned off**. If you use this function in singleton mode then it will only return one content string at a time.

&nbsp;

### `...GetContentMetadata()`

_Full function name:_ `ChatterboxGetContentMetadata(chatterbox, contentIndex)`

_Returns:_ Array, the metadata tags associated with the content

|Name          |Datatype                          |Purpose                                         |
|--------------|----------------------------------|------------------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`contentIndex`|integer                           |Content item to return                          |

&nbsp;

### `...GetContentCount()`

_Full function name:_ `ChatterboxGetContentCount(chatterbox)`

_Returns:_ Integer, the total number of content strings in the given [chatterbox](concept-chatterboxes)

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

### `...GetContentSpeech()`

_Full function name:_ `ChatterboxGetContentSpeech(chatterbox, contentIndex, [default])`

_Returns:_ String

|Name          |Datatype                          |Purpose                                                                                      |
|--------------|----------------------------------|---------------------------------------------------------------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                             |
|`contentIndex`|integer                           |Content item to return the speech for                                                        |
|`[default]`   |any                               |Default value to return if no valid speech is found. If not specified this is an empty string|

This is an optional function that adds additional helpful parsing capabilities to Chatterbox. For `ChatterboxGetContentSpeech()` to work properly, line of text in your Yarn file should be formatted like so:

```
Speaker Name: The words that the speaker is saying.
```

In this case, the "speech" part of this string is everything after the colon (`The words that the speaker is saying.`). Any whitespace that leads or follows speech is removed.

&nbsp;

### `...GetContentSpeaker()`

_Full function name:_ `ChatterboxGetContentSpeaker(chatterbox, contentIndex, [default])`

_Returns:_ String

|Name          |Datatype                          |Purpose                                                                                      |
|--------------|----------------------------------|---------------------------------------------------------------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                             |
|`contentIndex`|integer                           |Content item to return the speaker for                                                       |
|`[default]`   |any                               |Default value to return if no valid speech is found. If not specified this is an empty string|

This is an optional function that adds additional helpful parsing capabilities to Chatterbox. For `ChatterboxGetContentSpeaker()` to work properly, line of text in your Yarn file should be formatted like so:

```
Speaker Name: The words that the speaker is saying.
```

In this case, the "speaker" part of this string is everything before the colon (`Speaker Name`). Any whitespace that leads or follows the speaker name is removed. In the next example, "speaker data" is added to the line of text.

```
Speaker Name[additional speaker data]: The words that the speaker is saying.
```

The speaker part of this string is everything before the speaker data start symbol (see below), which is again `Speaker Name`.

&nbsp;

### `...GetContentSpeakerData()`

_Full function name:_ `ChatterboxGetContentSpeakerData(chatterbox, contentIndex, [default])`

_Returns:_ String

|Name          |Datatype                          |Purpose                                                                                      |
|--------------|----------------------------------|---------------------------------------------------------------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                             |
|`contentIndex`|integer                           |Content item to return the speaker data for                                                  |
|`[default]`   |any                               |Default value to return if no valid speech is found. If not specified this is an empty string|

This is an optional function that adds additional helpful parsing capabilities to Chatterbox. For `ChatterboxGetContentSpeakerData()` to work properly, line of text in your Yarn file should be formatted like so:

```
Speaker Name[additional speaker data]: The words that the speaker is saying.
```

In this case, the "speaker data" part of this string is everything between `[` and `]` (`additional speaker data`). Any whitespace that leads or follows the speaker data is removed. The symbols used to define where speaker data is stored is controlled by the `CHATTERBOX_SPEAKER_DATA_START` and `CHATTERBOX_SPEAKER_DATA_END` macros. Speaker data must follow the speaker's name and precede the colon that separates the speaker from the speech. If no speaker data is found, the provided default value is returned.

&nbsp;

### `...GetContentArray()`

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

&nbsp;

### `...GetOption()`

_Full function name:_ `ChatterboxGetOption(chatterbox, optionIndex)`

_Returns:_ String, option with the given index

|Name         |Datatype                          |Purpose                                         |
|-------------|----------------------------------|------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`optionIndex`|integer                           |Option item to return                           |

&nbsp;

### `...GetOptionMetadata()`

_Full function name:_ `ChatterboxGetOptionMetadata(chatterbox, optionIndex)`

_Returns:_ String, the metadata tags associated with the option

|Name         |Datatype                          |Purpose                                         |
|-------------|----------------------------------|------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`optionIndex`|integer                           |Option item to return                           |

&nbsp;

### `...GetOptionConditionBool()`

_Full function name:_ `ChatterboxGetOptionConditionBool(chatterbox, optionIndex)`

_Returns:_ Boolean, whether the option's if-statement passed

|Name         |Datatype                          |Purpose                                         |
|-------------|----------------------------------|------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`optionIndex`|integer                           |Option item to return                           |

If the option had no if-statement associated with it then this function will always return `true`.

&nbsp;

### `...GetOptionCount()`

_Full function name:_ `ChatterboxGetOptionCount(chatterbox)`

_Returns:_ Integer, the total number of option strings in the given [chatterbox](concept-chatterboxes)

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

### `...GetOptionArray()`

_Full function name:_ `ChatterboxGetOptionArray(chatterbox)`

_Returns:_ Array, containing one struct (see below) for each available option for the given chatterbox

|Name          |Datatype                          |Purpose                                         |
|--------------|----------------------------------|------------------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

The returned array is populated in canonical order: the 0th element of the array is equivalent to `ChatterboxGetOption(chatterbox, 0)` etc. Each struct in the array has this format:

|Member Variable |Purpose                                                       |
|----------------|--------------------------------------------------------------|
|`.text`         |The text for the option                                       |
|`.conditionBool`|Whether the conditional check for this option passed or failed|
|`.metadata`     |An array of metadata tags associated with the content         |

&nbsp

### `...GetCurrent()`

_Full function name:_ `ChatterboxGetCurrent(chatterbox)`

_Returns:_ String, the name of the node that the given [chatterbox](concept-chatterboxes) is currently on

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

### `...GetCurrentMetadata()`

_Full function name:_ `ChatterboxGetCurrentMetadata(chatterbox)`

_Returns:_ Array, the metadata associated with the node

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

### `...GetCurrentSource()`

_Full function name:_ `ChatterboxGetCurrentSource(chatterbox)`

_Returns:_ String, the name of the source that the given [chatterbox](concept-chatterboxes) is currently on

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|