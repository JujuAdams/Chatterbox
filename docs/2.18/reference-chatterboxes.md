# Chatterboxes

Functions on this page relate to chatterboxes, the basic machines that use source files as input and output strings of text that you can display in your game. Most functions on this page are prefixed with `Chatterbox`.

&nbsp;

## `ChatterboxCreate()`

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

## `IsChatterbox(value)`

_Full function name:_ `IsChatterbox(value)`

_Returns:_ Boolean, whether the given value is a [chatterbox](concept-chatterboxes)

|Name   |Datatype|Purpose           |
|-------|--------|------------------|
|`value`|any     |The value to check|

&nbsp;

## `...GetVisited()`

_Full function name:_ `ChatterboxGetVisited(nodeTitle, filename)`

_Returns:_ Number, how many times the given node has been visited

|Name      |Datatype|Purpose                                                 |
|----------|--------|--------------------------------------------------------|
|`nodeTile`|string  |Name of the node to check                               |
|`filename`|string  |Name of the [source file](concept-source-files) to check|

&nbsp;

## `...GetCurrent()`

_Full function name:_ `ChatterboxGetCurrent(chatterbox)`

_Returns:_ String, the name of the node that the given [chatterbox](concept-chatterboxes) is currently on

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

## `...GetPrevious()`

_Full function name:_ `ChatterboxGetPrevious(chatterbox)`

_Returns:_ String, the name of the node that the given [chatterbox](concept-chatterboxes) was previously on

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

!> This function will return `undefined` if there is no previous node (the current node is the first node that the chatterbox has visited).

&nbsp;

## `...GetCurrentMetadata()`

_Full function name:_ `ChatterboxGetCurrentMetadata(chatterbox)`

_Returns:_ Array, the metadata associated with the node

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

## `...GetCurrentSource()`

_Full function name:_ `ChatterboxGetCurrentSource(chatterbox)`

_Returns:_ String, the name of the source that the given [chatterbox](concept-chatterboxes) is currently on

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|