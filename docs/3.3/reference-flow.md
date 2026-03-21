# Flow Control

Functions on this page relate to controlling the flow of a chatterbox as it progresses through a ChatterScript file. All functions on this page are prefixed with `Chatterbox`.

&nbsp;

## `...Jump()`

_Full function name:_ `ChatterboxJump(chatterbox, nodeTitle, [filename])`

_Returns:_ N/A (`undefined`)

|Name        |Datatype                          |Purpose                                                                                                                                                                 |
|------------|----------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                                                                                                        |
|`nodeTitle` |string                            |Name of the node to jump to                                                                                                                                             |
|`[filename]`|string                            |[Source file](concept-source-files) to target. If not specified, the current [source file](concept-source-files) for the [chatterbox](concept-chatterboxes) will be used|

This function jumps to a specific node in a [source file](concept-source-files).

&nbsp;

## `...Continue()`

_Full function name:_ `ChatterboxContinue(chatterbox, [name=""])`

_Returns:_ N/A (`undefined`)

|Name        |Datatype                          |Purpose                                                                                                          |
|------------|----------------------------------|-----------------------------------------------------------------------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|[Chatterbox](concept-chatterboxes) to target. Use the special value `"all"` to continue all existing chatterboxes|
|`[name]`    |string                            |Name for the continue command. If not specified, the name defaults to `""`                                       |

Advances dialogue in a chatterbox that's "waiting", either due to a ChatterScript `<<wait>>` command, calling `ChatterboxWait()` or singleton behaviour.

The name is used to link continue commands to similarly named wait commands (either `<<wait name>>` or `ChatterboxWait(chatterbox, "name")`). This is helpful for cutscene systems where you might want to wait until a particular type of action has been completed but you don't want to write complex logic to link chatterbox state to cutscene state.

?> When calling this function it's often useful to know the current chatterbox that's being executed. You can access the current chatterbox by using the `CHATTERBOX_CURRENT` macro.

&nbsp;

## `...Select()`

_Full function name:_ `ChatterboxSelect(chatterbox, optionIndex)`

_Returns:_ N/A (`undefined`)

|Name         |Datatype                          |Purpose                                                                                                                  |
|-------------|----------------------------------|-------------------------------------------------------------------------------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                                                         |
|`optionIndex`|integer                           |Option to select, as detailed by [`chatterbox_get_option()`](reference-getters#chatterboxgetoptionchatterbox-optionindex)|

This function selects an option as defined by a ChatterScript shortcut (`->`).

&nbsp;

## `...SkipOptions()`

_Full function name:_ `ChatterboxSkipOptions(chatterbox)`

_Returns:_ N/A (`undefined`)

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

Skips the current block of options that the chatterbox is displaying. This function will do nothing if there are no options being shown.

&nbsp;

## `...Wait()`

_Full function name:_ `ChatterboxWait(chatterbox, [name=""])`

_Returns:_ N/A (`undefined`)

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`[name]`    |string                            |Name for the wait command. If not specified, the filter name defaults to `""`|

Forces a chatterbox to wait at the current instruction. This is similar to returning `"<<wait>>"` from a function called by an `<<action>>`.

The name is used to link continue commands to similarly named wait commands (either `<<wait name>>` or `ChatterboxWait(chatterbox, "name")`). This is helpful for cutscene systems where you might want to wait until a particular type of action has been completed but you don't want to write complex logic to link chatterbox state to cutscene state.

?> When calling this function it's often useful to know the current chatterbox that's being executed. You can access the current chatterbox by using the `CHATTERBOX_CURRENT` macro.

&nbsp;

## `...IsWaiting()`

_Full function name:_ `ChatterboxIsWaiting(chatterbox)`

_Returns:_ Boolean, whether the given [chatterbox](concept-chatterboxes) is in a "waiting" state, either due to a ChatterScript `<<wait>>` command or singleton behaviour

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

## `...IsStopped()`

_Full function name:_ `ChatterboxIsStopped(chatterbox)`

_Returns:_ Boolean, whether a [chatterbox](concept-chatterboxes) has stopped, either due to a `<<stop>>` command or because it has run out of content to display

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

## `...FastForward()`

_Full function name:_ `ChatterboxFastForward(chatterbox)`

_Returns:_ N/A (`undefined`)

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

Essentially a super-charged version of [`ChatterboxContinue()`](reference-flow#chatterboxcontinuechatterbox). Advances dialogue in a chatterbox all the way until the next occasion where the player is prompted to make a decision i.e. where options are being displayed and [`ChatterboxSelect()`](reference-flow#chatterboxselectchatterbox-optionindex) would be used. Fast forwarding ignores `<<wait>>` commands; if you'd like to force a fast forwarding chatterbox to wait then please use `<<forcewait>>` instead.

&nbsp;

## `...JumpBack()`

_Full function name:_ `ChatterboxJumpBack(chatterbox)`

_Returns:_ N/A (`undefined`)

|Name        |Datatype                          |Purpose                                                                                                                                                                 |
|------------|----------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                                                                                                        |

This function jumps to the previously visited node. If there is no previous node, this function does nothing.

?> `ChatterboxJumpBack()` doesn't use a stack and will literally jump back to previous node. This means calling `ChatterboxJumpBack()` multiple times in a row will bounce between two nodes.

&nbsp;

## `...Hop()`

_Full function name:_ `ChatterboxHop(chatterbox, nodeTitle, [filename])`

_Returns:_ N/A (`undefined`)

|Name        |Datatype                          |Purpose                                                                                                                                                                 |
|------------|----------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target                                                                                                                        |
|`nodeTitle` |string                            |Name of the node to jump to                                                                                                                                             |
|`[filename]`|string                            |[Source file](concept-source-files) to target. If not specified, the current [source file](concept-source-files) for the [chatterbox](concept-chatterboxes) will be used|

This function pushes the current node (and position in the node) to an internal stack, and then jumps to a specific node in a [source file](concept-source-files). You can then hop back to where you left off by calling `ChatterboxHopBack()`.

!> The hop stack is not available to be manually accessed or modified. The hop stack cannot be exported or imported. You should not rely on the hop stack to exist if you're handling savedata.

&nbsp;

## `...HopBack()`

_Full function name:_ `ChatterboxHopBack(chatterbox)`

_Returns:_ N/A (`undefined`)

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

This function pops a node and position from the internal stack, and then jumps to that specific node and position. Please see `ChatterboxHop()` above for more information.