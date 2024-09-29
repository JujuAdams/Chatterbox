# Getters Reference

---

### `chatterbox_get_content(chatterbox, contentIndex)`

*Returns:* String, content with the given index

|Name          |Datatype                  |Purpose                                 |
|--------------|--------------------------|----------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`contentIndex`|integer                   |Content item to return                  |

&nbsp;

&nbsp;

### `chatterbox_get_content_count(chatterbox)`

*Returns:* Integer, the total number of content strings in the given [chatterbox](concept-chatterboxes)

|Name          |Datatype                  |Purpose                                 |
|--------------|--------------------------|----------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

&nbsp;

### `chatterbox_get_option(chatterbox, optionIndex)`

*Returns:* String, option with the given index

|Name         |Datatype                  |Purpose                                 |
|-------------|--------------------------|----------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`optionIndex`|integer                   |Option item to return                   |

&nbsp;

&nbsp;

### `chatterbox_get_option_count(chatterbox)`

*Returns:* Integer, the total number of option strings in the given [chatterbox](concept-chatterboxes)

|Name          |Datatype                  |Purpose                                 |
|--------------|--------------------------|----------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

&nbsp;

### `chatterbox_visited(nodeTitle, [filename])`

*Returns:* Boolean, whether the given node has been visited

|Name        |Datatype|Purpose                                                                                  |
|------------|--------|-----------------------------------------------------------------------------------------|
|`nodeTile`  |string  |Name of the node to check                                                                |
|`[filename]`|string  |Name of the [source file](concept-source-files) to check. Defaults to a blank string, no filename|

&nbsp;

&nbsp;

### `chatterbox_get_current(chatterbox)`

*Returns:* String, the name of the node that the given [chatterbox](concept-chatterboxes) is currently on

|Name          |Datatype                  |Purpose                                 |
|--------------|--------------------------|----------------------------------------|
|`chatterbox`  |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|