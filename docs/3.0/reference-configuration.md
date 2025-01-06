# Configuration

The `__ChatterboxConfig()` script contains a multitude of macros that you can use to customise the behaviour of Chatterbox. `__ChatterboxConfig()` never needs to be directly called in code, but the script and the macros it contains must be present in a project for Chatterbox to work.

!> You should edit `__ChatterboxConfig()` to customise Chatterbox for your own purposes.

&nbsp;

## `CHATTERBOX_DEFAULT_SINGLETON`

_Typical value:_ `true`

Whether chatterboxes should default to being singleton.

&nbsp;

## `CHATTERBOX_ALLOW_SCRIPTS`

_Typical value:_ `true`

Whether to allow scripts to be added as Chatterbox functions.

&nbsp;

## `CHATTERBOX_FUNCTION_ARRAY_ARGUMENTS`

_Typical value:_ `true`

Whether to execute callbacks with an array of arguments. Setting this to `false` will execute callbacks with individual arguments.

&nbsp;

## `CHATTERBOX_SINGLETON_WAIT_BEFORE_OPTION`

_Typical value:_ `false`

Whether a chatterbox will enter into a waiting state before options are enumerated.

&nbsp;

## `CHATTERBOX_WAIT_BEFORE_STOP`

_Typical value:_ `true`

Whether a chatterbox will enter into a waiting state before a chatterbox goes into a `<<stop>>` state.

&nbsp;

## `CHATTERBOX_VERBOSE`

_Typical value:_ `false`

Whether Chatterbox will send lots of potentially useful debug information to the output log. You may find this debug information distracting, especially after you get more comfortable with Chatterbox, so you may want to set this macro to `false` to clean up your debug log. Warning messages are not turned off by `CHATTERBOX_VERBOSE`.

&nbsp;

## `CHATTERBOX_REPLACE_ALIAS_BACKSLASHES`

_Typical value:_ `true`

Set to `true` to automatically replace backslashes `\` in paths for forward slashes `/`. This standardises path references making a number of path-related arguments consistent across many Chatterbox functions. Setting this macro to `false` will turn off slash replacement and may result in, for example, files being reported as non-existent or not loaded.

&nbsp;

## `CHATTERBOX_KEYWORD_OPERATORS`

_Typical value:_ `true`

Whether to allow use of keyword operators. Setting this macro to `true` will enable use of the following operators as keywords:

|Keyword|Operator|
|-------|--------|
|`and`  |`&&`    |
|`le`   |`<`     |
|`lt`   |`<`     |
|`ge`   |`>`     |
|`gt`   |`>`     |
|`or`   |`||`    |
|`lte`  |`<=`    |
|`gte`  |`>=`    |
|`leq`  |`<=`    |
|`geq`  |`>=`    |
|`eq`   |`==`    |
|`is`   |`==`    |
|`neq`  |`!=`    |
|`to`   |`=`     |
|`not`  |`!`     |

&nbsp;

## `CHATTERBOX_SHOW_REJECTED_OPTIONS`

_Typical value:_ `true`

Whether to expose options whose conditional check has failed. Setting this to `false` will never expose rejected options.

&nbsp;

## `CHATTERBOX_END_OF_NODE_HOPBACK`

_Typical value:_ `true`

Whether nodes without an explicit `<<stop>>` or `<<hopback>>` instruct at the end should default to `<<hopback>>`. Legacy behaviour (pre-2.7) is to set this to `false`.

&nbsp;

## `CHATTERBOX_ACTION_MODE`

_Typical value:_ `1`

`CHATTERBOX_ACTION_MODE` should be either 0, 1, or 2:

- `0` Pass ChatterScript actions as a raw string to a function, defined by `CHATTERBOX_ACTION_FUNCTION`
- `1` Treat actions as expressions
- `2` Treat actions as they were in version 1 (Python-esque function calls)

### `CHATTERBOX_ACTION_MODE` = 0

This is the officially recommended behaviour. The full contents of the direction (everything between `<<` and `>>`) are passed as a string to a function for parsing and execution by the developer (you). I think this behaviour is stupid but I've included it here because technically that is what the ChatterScript specification says. You can set the function that receives the direction string by setting `CHATTERBOX_ACTION_FUNCTION`. Exactly what syntax you use for actions is therefore completely up to you.

### `CHATTERBOX_ACTION_MODE` = 1

Chatterbox will treat actions as expressions to be executed in a similar manner to in-line expressions. This is covenient if you want to treat actions as little snippets of code that Chatterbox can run. Syntax for actions becomes the same as in-line expressions, which is broadly similar to "standard" GML syntax. Functions that you wish to execute must be added by calling ChatterboxAddFunction(). An example would be: `<<giveItem("amulet", 1)>>`

### `CHATTERBOX_ACTION_MODE` = 2

Chatterbox will treat actions as expressions with a greatly simplified syntax. This is useful for writers and narrative designers who are less familiar with the particulars of coding and instead want to use a simple syntax to communicate with the underlying GameMaker application. The direction is sliced into arguments using spaces as delimiters. The first token in the direction is the name of the function call, as added by `ChatterboxAddFunction()`. Subsequent tokens are passed to the function call with each token being a function parameter. All parameters are passed as strings. If a parameter needs to contain a space then you may enclose the string in `"` double quote marks. An example, analogous to the example above, would be: `<<giveItem amulet 1>>`.

&nbsp;

## `CHATTERBOX_DIRECTION_FUNCTION`

_Typical value:_ `ExampleActionFunction`

Function to use to handle actions. This only applies in mode `0` (see below).

&nbsp;

## `CHATTERBOX_END_OF_NODE_HOPBACK`

_Typical value:_ `true`

Whether nodes without an explicit `<<stop>>` or `<<hopback>>` command at the end should default to `<<hopback>>`. Legacy behaviour (pre-2.7) is to set this to `false`.

&nbsp;

### `CHATTERBOX_SPEAKER_DELIMITER`

_Typical value:_ `":"`

Character that separates speaker (and speaker data) from speech. This can be any arbitrary string, potentially composed of multiple characters. Please see the [speakers documentation](concept-metadata-and-speakers?id=speakers) for more information.

&nbsp;

## `CHATTERBOX_SPEAKER_DATA_START`

_Typical value:_ `"["`

Character that indicates where the speaker data string starts. This can be any arbitrary string, potentially composed of multiple characters. Please see the [speakers documentation](concept-metadata-and-speakers?id=speakers) for more information.

&nbsp;

## `CHATTERBOX_SPEAKER_DATA_END`

_Typical value:_ `"]"`

WCharacter that indicates where the speaker data string ends. This can be any arbitrary string, potentially composed of multiple characters. Please see the [speakers documentation](concept-metadata-and-speakers?id=speakers) for more information.

&nbsp;

### `CHATTERBOX_ESCAPE_FILE_TAGS`

_Typical value:_ `true`

Whether file metadata tags are [escaped](https://en.wikipedia.org/wiki/Escape_character).

&nbsp;

## `CHATTERBOX_ESCAPE_NODE_TAGS`

_Typical value:_ `true`

Whether node metadata tags are [escaped](https://en.wikipedia.org/wiki/Escape_character).

&nbsp;

## `CHATTERBOX_ESCAPE_CONTENT`

_Typical value:_ `true`

Whether content strings are [escaped](https://en.wikipedia.org/wiki/Escape_character).

&nbsp;

## `CHATTERBOX_ESCAPE_EXPRESSION_STRINGS`

_Typical value:_ `false`

Whether expression strings are [escaped](https://en.wikipedia.org/wiki/Escape_character).

&nbsp;

## `CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY`

_Typical value:_ `""` (empty string)

Directory inside Included Files that holds all external ChatterScript files. Use an empty string for the root of Included Files.

&nbsp;

## `CHATTERBOX_DECLARE_ON_COMPILE`

_Typical value:_ `true`

Whether to declare variables when Chatterbox script is compiled. Set to `false` for legacy (2.1 and earlier) behaviour.

&nbsp;

## `CHATTERBOX_LEGACY_WEIRD_OPERATOR_PRECEDENCE`

_Typical value:_ `false`

&nbsp;

## `CHATTERBOX_INDENT_TAB_SIZE`

_Typical value:_ `4`

Size of tabs for ChatterScript input.

&nbsp;

## `CHATTERBOX_FILENAME_SEPARATOR`

_Typical value:_ `":"`

Separator to use to concatenate filenames to node names, used to reference nodes in other source files.

&nbsp;

## `CHATTERBOX_ERROR_NONSTANDARD_SYNTAX`

_Typical value:_ `true`

Whether to throw an error when using a reasonable, though technically incorrect, syntax e.g. `<<end if>>` or `<<elseif>>`.

&nbsp;

## `CHATTERBOX_ERROR_UNDECLARED_VARIABLE`

_Typical value:_ `true`

Throws an error when trying to set a variable that has not been declared (either using `<<declare>>` or `ChatterboxVariableDefault()`).

&nbsp;

## `CHATTERBOX_ERROR_UNSET_VARIABLE`

_Typical value:_ `true`

Throws an error when trying to read a variable that doesn't exist.

&nbsp;

## `CHATTERBOX_ERROR_REDECLARED_VARIABLE`

_Typical value:_ `true`

Throws an error when trying to redeclare a variable (either using `<<declare>>` or `ChatterboxVariableDefault()`).

&nbsp;

## `CHATTERBOX_ERROR_NO_LOCAL_SCOPE`

_Typical value:_ `true`

Throws an error when trying to execute a function without a local scope being available.

&nbsp;

## `CHATTERBOX_VARIABLE_MISSING_VALUE`

_Typical value:_ `0`

Value to return from a variable that doesn't exist. This is only relevant if `CHATTERBOX_ERROR_UNSET_VARIABLE` is `false` and the `default` argument for `ChatterboxVariableGet()` has not been specified.
