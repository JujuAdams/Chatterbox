# Option Getters

Functions on this page relate to getting option data from a chatterbox. All functions on this page are prefixed with `ChatterboxGet`.

&nbsp;

### `...Option()`

_Full function name:_ `ChatterboxGetOption(chatterbox, optionIndex)`

_Returns:_ String, option with the given index

|Name         |Datatype                          |Purpose                                         |
|-------------|----------------------------------|------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`optionIndex`|integer                           |Option item to return                           |

&nbsp;

### `...OptionMetadata()`

_Full function name:_ `ChatterboxGetOptionMetadata(chatterbox, optionIndex)`

_Returns:_ String, the metadata tags associated with the option

|Name         |Datatype                          |Purpose                                         |
|-------------|----------------------------------|------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`optionIndex`|integer                           |Option item to return                           |

&nbsp;

### `...OptionConditionBool()`

_Full function name:_ `ChatterboxGetOptionConditionBool(chatterbox, optionIndex)`

_Returns:_ Boolean, whether the option's if-statement passed

|Name         |Datatype                          |Purpose                                         |
|-------------|----------------------------------|------------------------------------------------|
|`chatterbox` |[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|
|`optionIndex`|integer                           |Option item to return                           |

If the option had no if-statement associated with it then this function will always return `true`.

&nbsp;

### `...OptionCount()`

_Full function name:_ `ChatterboxGetOptionCount(chatterbox)`

_Returns:_ Integer, the total number of option strings in the given [chatterbox](concept-chatterboxes)

|Name        |Datatype                          |Purpose                                         |
|------------|----------------------------------|------------------------------------------------|
|`chatterbox`|[chatterbox](concept-chatterboxes)|The [chatterbox](concept-chatterboxes) to target|

&nbsp;

### `...OptionArray()`

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