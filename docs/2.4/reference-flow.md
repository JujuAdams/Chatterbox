# Flow Reference

---

### `ChatterboxJump(chatterbox, nodeTitle, [filename])`

_Returns:_ N/A (`undefined`)

| Name         | Datatype                           | Purpose                                                                                                                                                                  |
| ------------ | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `chatterbox` | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target                                                                                                                         |
| `nodeTitle`  | string                             | Name of the node to jump to                                                                                                                                              |
| `[filename]` | string                             | [Source file](concept-source-files) to target. If not specified, the current [source file](concept-source-files) for the [chatterbox](concept-chatterboxes) will be used |

This function jumps to a specific node in a [source file](concept-source-files).

&nbsp;

---

### `ChatterboxSelect(chatterbox, optionIndex)`

_Returns:_ N/A (`undefined`)

| Name          | Datatype                           | Purpose                                                                                                                   |
| ------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `chatterbox`  | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target                                                                          |
| `optionIndex` | integer                            | Option to select, as detailed by [`chatterbox_get_option()`](reference-getters#chatterboxgetoptionchatterbox-optionindex) |

This function selects an option as defined by a Yarn shortcut (`->`).

&nbsp;

---

### `ChatterboxContinue(chatterbox)`

_Returns:_ N/A (`undefined`)

| Name         | Datatype                           | Purpose                                          |
| ------------ | ---------------------------------- | ------------------------------------------------ |
| `chatterbox` | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |

Advances dialogue in a chatterbox that's "waiting", either due to a Yarn `<<wait>>` command, calling `ChatterboxWait()` or singleton behaviour.

&nbsp;

---

### `ChatterboxWait(chatterbox)`

_Returns:_ N/A (`undefined`)

| Name         | Datatype                           | Purpose                                          |
| ------------ | ---------------------------------- | ------------------------------------------------ |
| `chatterbox` | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |

Forces a chatterbox to wait at the current instruction. This is similar to returning `"<<wait>>"` from a function called by an `<<action>>`.

?> When calling this function it's often useful to know the current chatterbox that's being executed. You can access the current chatterbox by using the `CHATTERBOX_CURRENT` macro.

&nbsp;

---

### `ChatterboxIsWaiting(chatterbox)`

_Returns:_ Boolean, whether the given [chatterbox](concept-chatterboxes) is in a "waiting" state, either due to a Yarn `<<wait>>` command or singleton behaviour

| Name         | Datatype                           | Purpose                                          |
| ------------ | ---------------------------------- | ------------------------------------------------ |
| `chatterbox` | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |

&nbsp;

---

### `ChatterboxIsStopped(chatterbox)`

_Returns:_ Boolean, whether a [chatterbox](concept-chatterboxes) has stopped, either due to a `<<stop>>` command or because it has run out of content to display

| Name         | Datatype                           | Purpose                                          |
| ------------ | ---------------------------------- | ------------------------------------------------ |
| `chatterbox` | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |

&nbsp;

---

### `chatterboxFastForward(chatterbox)`

_Returns:_ N/A (`undefined`)

| Name         | Datatype                           | Purpose                                          |
| ------------ | ---------------------------------- | ------------------------------------------------ |
| `chatterbox` | [chatterbox](concept-chatterboxes) | The [chatterbox](concept-chatterboxes) to target |

Essentially a super-charged version of [`ChatterboxContinue()`](reference-flow#chatterboxcontinuechatterbox). Advances dialogue in a chatterbox all the way until the next occasion where the player is prompted to make a decision i.e. where options are being displayed and [`ChatterboxSelect()`](reference-flow#chatterboxselectchatterbox-optionindex) would be used.