# Getters Reference

---

### `ChatterboxGetVisited(nodeTitle, [filename])`

_Returns:_ Boolean, whether the given node has been visited

| Name         | Datatype | Purpose                                                                                           |
| ------------ | -------- | ------------------------------------------------------------------------------------------------- |
| `nodeTile`   | string   | Name of the node to check                                                                         |
| `[filename]` | string   | Name of the [source file](concept-source-files) to check. Defaults to a blank string, no filename |

&nbsp;

---

### `ChatterboxGetContent(chatterbox, contentIndex)`

_Returns:_ String, content with the given index

| Name           | Datatype                           | Purpose                                          |
| -------------- | ---------------------------------- | ------------------------------------------------ |
| `chatterbox`   | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |
| `contentIndex` | integer                            | Content item to return                           |

&nbsp;

---

### `ChatterboxGetContentMetadata(chatterbox, contentIndex)`

_Returns:_ Array, the metadata tags associated with the content

| Name           | Datatype                           | Purpose                                          |
| -------------- | ---------------------------------- | ------------------------------------------------ |
| `chatterbox`   | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |
| `contentIndex` | integer                            | Content item to return                           |

&nbsp;

---

### `ChatterboxGetContentCount(chatterbox)`

_Returns:_ Integer, the total number of content strings in the given [chatterbox](concept-chatterboxes)

| Name         | Datatype                           | Purpose                                          |
| ------------ | ---------------------------------- | ------------------------------------------------ |
| `chatterbox` | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |

&nbsp;

---

### `ChatterboxGetContentSpeech(chatterbox, contentIndex, [default])`

_Returns:_ String

| Name           | Datatype                           | Purpose                                                                                       |
| -------------- | ---------------------------------- | --------------------------------------------------------------------------------------------- |
| `chatterbox`   | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target                                              |
| `contentIndex` | integer                            | Content item to return the speech for                                                         |
| `[default]`    | any                                | Default value to return if no valid speech is found. If not specified this is an empty string |

This is an optional function that adds additional helpful parsing capabilities to Chatterbox. For `ChatterboxGetContentSpeech()` to work properly, line of text in your Yarn file should be formatted like so:

```
Speaker Name: The words that the speaker is saying.
```

In this case, the "speech" part of this string is everything after the colon (`The words that the speaker is saying.`). Any whitespace that leads or follows speech is removed.

&nbsp;

---

### `ChatterboxGetContentSpeaker(chatterbox, contentIndex, [default])`

_Returns:_ String

| Name           | Datatype                           | Purpose                                                                                       |
| -------------- | ---------------------------------- | --------------------------------------------------------------------------------------------- |
| `chatterbox`   | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target                                              |
| `contentIndex` | integer                            | Content item to return the speaker for                                                        |
| `[default]`    | any                                | Default value to return if no valid speech is found. If not specified this is an empty string |

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

---

### `ChatterboxGetContentSpeakerData(chatterbox, contentIndex, [default])`

_Returns:_ String

| Name           | Datatype                           | Purpose                                                                                       |
| -------------- | ---------------------------------- | --------------------------------------------------------------------------------------------- |
| `chatterbox`   | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target                                              |
| `contentIndex` | integer                            | Content item to return the speaker data for                                                   |
| `[default]`    | any                                | Default value to return if no valid speech is found. If not specified this is an empty string |

This is an optional function that adds additional helpful parsing capabilities to Chatterbox. For `ChatterboxGetContentSpeakerData()` to work properly, line of text in your Yarn file should be formatted like so:

```
Speaker Name[additional speaker data]: The words that the speaker is saying.
```

In this case, the "speaker data" part of this string is everything between `[` and `]` (`additional speaker data`). Any whitespace that leads or follows the speaker data is removed. The symbols used to define where speaker data is stored is controlled by the `CHATTERBOX_SPEAKER_DATA_START` and `CHATTERBOX_SPEAKER_DATA_END` macros. Speaker data must follow the speaker's name and precede the colon that separates the speaker from the speech. If no speaker data is found, the provided default value is returned.

&nbsp;

---

### `ChatterboxGetContentArray(chatterbox)`

_Returns:_ Array, containing one struct (see below) for each available content string for the given chatterbox

| Name           | Datatype                           | Purpose                                          |
| -------------- | ---------------------------------- | ------------------------------------------------ |
| `chatterbox`   | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |

The returned array is populated in canonical order: the 0th element of the array is equivalent to `ChatterboxGetContent(chatterbox, 0)` etc. Each struct in the array has this format:

| Member Variable | Purpose                                               |
| --------------- | ----------------------------------------------------- |
| `.text`         | The text for the content string                       |
| `.metadata`     | An array of metadata tags associated with the content |

?> This function is intended for use with singleton mode **turned off**. If you use this function in singleton mode then it will only return one content string at a time.

&nbsp;

---

### `ChatterboxGetOption(chatterbox, optionIndex)`

_Returns:_ String, option with the given index

| Name          | Datatype                           | Purpose                                          |
| ------------- | ---------------------------------- | ------------------------------------------------ |
| `chatterbox`  | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |
| `optionIndex` | integer                            | Option item to return                            |

&nbsp;

---

### `ChatterboxGetOptionMetadata(chatterbox, optionIndex)`

_Returns:_ String, the metadata tags associated with the option

| Name          | Datatype                           | Purpose                                          |
| ------------- | ---------------------------------- | ------------------------------------------------ |
| `chatterbox`  | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |
| `optionIndex` | integer                            | Option item to return                            |

&nbsp;

---

### `ChatterboxGetOptionConditionBool(chatterbox, optionIndex)`

_Returns:_ Boolean, whether the option's if-statement passed

| Name          | Datatype                           | Purpose                                          |
| ------------- | ---------------------------------- | ------------------------------------------------ |
| `chatterbox`  | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |
| `optionIndex` | integer                            | Option item to return                            |

If the option had no if-statement associated with it then this function will always return `true`.

&nbsp;

---

### `ChatterboxGetOptionCount(chatterbox)`

_Returns:_ Integer, the total number of option strings in the given [chatterbox](concept-chatterboxes)

| Name         | Datatype                           | Purpose                                          |
| ------------ | ---------------------------------- | ------------------------------------------------ |
| `chatterbox` | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |

&nbsp;

---

### `ChatterboxGetOptionArray(chatterbox)`

_Returns:_ Array, containing one struct (see below) for each available option for the given chatterbox

| Name           | Datatype                           | Purpose                                          |
| -------------- | ---------------------------------- | ------------------------------------------------ |
| `chatterbox`   | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |

The returned array is populated in canonical order: the 0th element of the array is equivalent to `ChatterboxGetOption(chatterbox, 0)` etc. Each struct in the array has this format:

| Member Variable  | Purpose                                                        |
| ---------------- | -------------------------------------------------------------- |
| `.text`          | The text for the option                                        |
| `.conditionBool` | Whether the conditional check for this option passed or failed |
| `.metadata`      | An array of metadata tags associated with the content          |

&nbsp

---

### `ChatterboxGetCurrent(chatterbox)`

_Returns:_ String, the name of the node that the given [chatterbox](concept-chatterboxes) is currently on

| Name         | Datatype                           | Purpose                                          |
| ------------ | ---------------------------------- | ------------------------------------------------ |
| `chatterbox` | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |

&nbsp;

---

### `ChatterboxGetCurrentMetadata(chatterbox)`

_Returns:_ Array, the metadata associated with the node

| Name         | Datatype                           | Purpose                                          |
| ------------ | ---------------------------------- | ------------------------------------------------ |
| `chatterbox` | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |

&nbsp;

---

### `ChatterboxGetCurrentSource(chatterbox)`

_Returns:_ String, the name of the source that the given [chatterbox](concept-chatterboxes) is currently on

| Name         | Datatype                           | Purpose                                          |
| ------------ | ---------------------------------- | ------------------------------------------------ |
| `chatterbox` | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |
