# Chatterboxes Reference

---

### `chatterbox_create([filename], [singletonText])`

*Returns:* A new [chatterbox](Chatterboxes)

|Name             |Datatype|Purpose                                                                                                                         |
|-----------------|--------|--------------------------------------------------------------------------------------------------------------------------------|
|`[filename]`     |string  |[Source file](concept-source-files) to target. If not specified, the default [source file](concept-source-files) will be used (the first [source file](concept-source-files) that was [loaded](reference-configuration#chatterbox_loadfilename) into Chatterbox)|
|`[singletonText]`|boolean |Whether content is revealed one line at a time (see below). If not specified, [`CHATTERBOX_DEFAULT_SINGLETON`](reference-configuration#__chatterbox_config) is used instead|

If `singletonText` is set to `true` then dialogue will be outputted one line at a time. This is typical behaviour for RPGs like Pokémon or Final Fantasy where characters talk one at a time. Only one piece of dialogue will be shown at a time.

However, if `singletonText` is set to `false` then dialogue will be outputted multiple lines at a time. More modern narrative games, especially those by Inkle or Failbetter, tend to show larger blocks of text. Content will be stacked up until Chatterbox reaches a command that requires user input: a shortcut, an option, or a `<<stop>>` or `<<wait>>` command.

&nbsp;

&nbsp;

### `is_chatterbox(value)`

*Returns:* Boolean, whether the given value is a [chatterbox](concept-chatterboxes)

|Name   |Datatype|Purpose           |
|-------|--------|------------------|
|`value`|any     |The value to check|

&nbsp;

&nbsp;

### `chatterbox_is_waiting(chatterbox)`

*Returns:* Boolean, whether the given [chatterbox](concept-chatterboxes) is in a "waiting" state, either due to a Yarn `<<wait>>` command or singleton behaviour

|Name         |Datatype                  |Purpose                                 |
|-------------|--------------------------|----------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

&nbsp;

### `chatterbox_is_stopped(chatterbox)`

*Returns:* Boolean, whether a [chatterbox](concept-chatterboxes) has stopped, either due to a `<<stop>>` command or because it has run out of content to display

|Name         |Datatype                  |Purpose                                 |
|-------------|--------------------------|----------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|