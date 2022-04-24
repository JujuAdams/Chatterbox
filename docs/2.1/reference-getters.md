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
