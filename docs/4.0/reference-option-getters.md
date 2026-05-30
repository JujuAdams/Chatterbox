# Option Getters

Functions on this page relate to getting option data from a chatterbox. All functions on this page are prefixed with `ChatterboxGet`.

&nbsp;

## `...Option()`

_Full function name:_ `ChatterboxGetOption(chatterbox, optionIndex)`

_Returns:_ String, option with the given index

|Name         |Datatype                          |Purpose                                         |
|-------------|----------------------------------|------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`optionIndex`|integer                           |Option item to return                           |

&nbsp;

## `...OptionMetadata()`

_Full function name:_ `ChatterboxGetOptionMetadata(chatterbox, optionIndex)`

_Returns:_ String, the metadata tags associated with the option

|Name         |Datatype                          |Purpose                                         |
|-------------|----------------------------------|------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`optionIndex`|integer                           |Option item to return                           |

&nbsp;

## `...OptionConditionBool()`

_Full function name:_ `ChatterboxGetOptionConditionBool(chatterbox, optionIndex)`

_Returns:_ Boolean, whether the option's if-statement passed

|Name         |Datatype                          |Purpose                                         |
|-------------|----------------------------------|------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`optionIndex`|integer                           |Option item to return                           |

If the option had no if-statement associated with it then this function will always return `true`.

&nbsp;

## `...OptionHasCondition()`

_Full function name:_ `ChatterboxGetOptionHasCondition(chatterbox, optionIndex)`

_Returns:_ Boolean, whether the option has an attached if-statement

|Name         |Datatype                          |Purpose                                         |
|-------------|----------------------------------|------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`optionIndex`|integer                           |Option item to target                           |

&nbsp;


## `...OptionChosen()`

_Full function name:_ `ChatterboxGetOptionChosen(chatterbox, optionIndex)`

_Returns:_ Number, how many times the option has been chosen

|Name         |Datatype                          |Purpose                                         |
|-------------|----------------------------------|------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`optionIndex`|integer                           |Option item to return                           |

If the option has not been chosen at all, this function will return `0`.

&nbsp;

## `...OptionCount()`

_Full function name:_ `ChatterboxGetOptionCount(chatterbox)`

_Returns:_ Integer, the total number of option strings in the given [chatterbox](concept-chatterboxes)

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

## `...FindOptionWithMetadata()`

_Full function name:_ `ChatterboxFindOptionWithMetadata(chatterbox, metadata, [respectCondition=true])`

_Returns:_ Number, index of the option with the given metadata string.

|Name                |Datatype                          |Purpose                                                             |
|--------------------|----------------------------------|--------------------------------------------------------------------|
|`chatterbox`        |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                    |
|`metadata`          |string                            |Metadata string to search for                                       |
|`[respectCondition]`|boolean                           |Whether to filter out options that have failed their condition check|

If there are multiple options that contain the metadata string then the first option index is returned. If no option has the metadata string then this function returns `undefined`.

If the optional `respectCondition` parameter is set to `true` (as it is by default) then this function will always ignore options that have failed their condition check (if they have one).

&nbsp;

## `...GetOptionContainsMetadata()`

_Full function name:_ `ChatterboxGetOptionContainsMetadata(chatterbox, optionIndex, metadata, [respectCondition=true])`

_Returns:_ Boolean, whether the given option contains a particular metadata string

|Name                |Datatype                          |Purpose                                                             |
|--------------------|----------------------------------|--------------------------------------------------------------------|
|`chatterbox`        |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                    |
|`optionIndex`       |integer                           |Option item to target                                               |
|`metadata`          |string                            |Metadata string to search for                                       |
|`[respectCondition]`|boolean                           |Whether to filter out options that have failed their condition check|

If the index provided is out of bounds then this function will return `false`.

If the optional `respectCondition` parameter is set to `true` (as it is by default) then this function will always return `false` if the option failed its condition check.

&nbsp;

## `...OptionArray()`

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

&nbsp;

## `...OptionSpeech()`

_Full function name:_ `ChatterboxGetOptionSpeech(chatterbox, optionIndex, [default])`

_Returns:_ String

|Name         |Datatype                          |Purpose                                                                                      |
|-------------|----------------------------------|---------------------------------------------------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                             |
|`optionIndex`|integer                           |Option to return the speaker data for                                                        |
|`[default]`  |any                               |Default value to return if no valid speech is found. If not specified this is an empty string|

This is an optional function that adds additional helpful parsing capabilities to Chatterbox. For `ChatterboxGetOptionSpeech()` to work properly, line of text in your ChatterScript file should be formatted like so:

```
-> Speaker Name: The words that the speaker is saying.
```

In this case, the "speech" part of this string is everything after the colon (`The words that the speaker is saying.`). Any whitespace that leads or follows speech is removed.

&nbsp;

## `...OptionSpeaker()`

_Full function name:_ `ChatterboxGetOptionSpeaker(chatterbox, contentIndex, [default])`

_Returns:_ String

|Name         |Datatype                          |Purpose                                                                                      |
|-------------|----------------------------------|---------------------------------------------------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                             |
|`optionIndex`|integer                           |Option to return the speaker data for                                                        |
|`[default]`  |any                               |Default value to return if no valid speech is found. If not specified this is an empty string|

This is an optional function that adds additional helpful parsing capabilities to Chatterbox. For `ChatterboxGetOptionSpeaker()` to work properly, line of text in your ChatterScript file should be formatted like so:

```
Speaker Name: The words that the speaker is saying.
```

In this case, the "speaker" part of this string is everything before the colon (`Speaker Name`). Any whitespace that leads or follows the speaker name is removed. In the next example, "speaker data" is added to the line of text.

```
-> Speaker Name[additional speaker data]: The words that the speaker is saying.
```

The speaker part of this string is everything before the speaker data start symbol (see below), which is again `Speaker Name`.

&nbsp;

## `...OptionSpeakerData()`

_Full function name:_ `ChatterboxGetOptionSpeakerData(chatterbox, contentIndex, [default])`

_Returns:_ String

|Name         |Datatype                          |Purpose                                                                                      |
|-------------|----------------------------------|---------------------------------------------------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                             |
|`optionIndex`|integer                           |Option to return the speaker data for                                                        |
|`[default]`  |any                               |Default value to return if no valid speech is found. If not specified this is an empty string|

This is an optional function that adds additional helpful parsing capabilities to Chatterbox. For `ChatterboxGetOptionSpeakerData()` to work properly, line of text in your ChatterScript file should be formatted like so:

```
-> Speaker Name[additional speaker data]: The words that the speaker is saying.
```

In this case, the "speaker data" part of this string is everything between `[` and `]` (`additional speaker data`). Any whitespace that leads or follows the speaker data is removed. The symbols used to define where speaker data is stored is controlled by the `CHATTERBOX_SPEAKER_DATA_START` and `CHATTERBOX_SPEAKER_DATA_END` macros. Speaker data must follow the speaker's name and precede the colon that separates the speaker from the speech. If no speaker data is found, the provided default value is returned.

&nbsp;