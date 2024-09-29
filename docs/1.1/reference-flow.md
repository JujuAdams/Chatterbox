# Flow Reference

---

### `chatterbox_goto(chatterbox, nodeTitle, [filename])`

*Returns:* N/A (`undefined`)

|Name        |Datatype                  |Purpose                                 |
|------------|--------------------------|----------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`nodeTitle` |string                    |Yarn node to jump to                    |
|`[filename]`|string                    |[Source file](concept-source-files) to target. If not specified, the current [source file](concept-source-files) for the [chatterbox](concept-chatterboxes) will be used|

This function jumps to a specific node in a [source file](concept-source-files).

&nbsp;

&nbsp;

### `chatterbox_select(chatterbox, optionIndex)`

*Returns:* N/A (`undefined`)

|Name         |Datatype                  |Purpose                                                                                      |
|-------------|--------------------------|---------------------------------------------------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                                     |
|`optionIndex`|integer                   |Option to select, as detailed by [`chatterbox_get_option()`](reference-getters#chatterbox_get_optionchatterbox-optionindex)|

This function selects an option, either defined by a Yarn shortcut (`->`) or a Yarn option (`[[text|node]]`).

&nbsp;

&nbsp;

### `chatterbox_continue(chatterbox)`

*Returns:* N/A (`undefined`)

|Name        |Datatype                  |Purpose                                 |
|------------|--------------------------|----------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

Advances dialogue in a chatterbox that's "waiting", either due to a Yarn `<<wait>>` command or singleton behaviour.

&nbsp;

&nbsp;

### `chatterbox_fast_forward(chatterbox)`

*Returns:* N/A (`undefined`)

|Name        |Datatype                  |Purpose                                 |
|------------|--------------------------|----------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

Essentially a super-charged version of [`chatterbox_continue()`](reference-flow#chatterbox_continuechatterbox). Advances dialogue in a chatterbox all the way until the next occasion where the player is prompted to make a decision i.e. where options are being displayed and [`chatterbox_select()`](reference-flow#chatterbox_selectchatterbox-optionindex) would be used.