<h1 align="center">Configuration Reference</h1>

---

### `__ChatterboxConfig()`

_Returns:_ N/A (`undefined`)

| Name | Datatype | Purpose |
| ---- | -------- | ------- |
| None |          |         |

This script holds a number of macros that customise the behaviour of Chatterbox. `__ChatterboxConfig()` never needs to be directly called in code, but the script and the macros it contains must be present in a project for Chatterbox to work.

**You should edit this script to customise Chatterbox for your own purposes.**

&nbsp;

| Macro                                     | Typical value                   | Purpose                                                                                                                           |
| ----------------------------------------- | ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `CHATTERBOX_VARIABLES_MAP`                | `global.chatterboxVariablesMap` | Global variable to use to store Chatterbox variables                                                                              |
| `CHATTERBOX_DEFAULT_SINGLETON`            | `true`                          | Whether chatterboxes should default to being singleton                                                                            |
| `CHATTERBOX_ALLOW_SCRIPTS`                | `true`                          | Whether to allow scripts to be added as Chatterbox functions                                                                      |
| `CHATTERBOX_FUNCTION_ARRAY_ARGUMENTS`     | `true`                          | Whether to execute callbacks with an array of arguments. Setting this to `false` will execute callbacks with individual arguments |
| `CHATTERBOX_SINGLETON_WAIT_BEFORE_OPTION` | `false`                         | Whether a chatterbox will enter into a waiting state before options are enumerated                                                |
| `CHATTERBOX_WAIT_BEFORE_STOP`             | `true`                          | Whether a chatterbox will enter into a waiting state before a chatterbox goes into a `<<stop>>` state                             |
| `CHATTERBOX_SHOW_REJECTED_OPTIONS`        | `true`                          | Whether to expose options whose conditional check has failed. Setting this to `false` will never expose rejected options          |
| `CHATTERBOX_DIRECTION_MODE`               | `0`                             | See below                                                                                                                         |
| `CHATTERBOX_DIRECTION_FUNCTION`           | `TestCaseDirectionFunction`     | Function to use to handle directions. This only applies in mode 0 (see below)                                                     |
| `CHATTERBOX_ESCAPE_FILE_TAGS`             | `true`                          | Whether file metadata tags are [escaped](https://en.wikipedia.org/wiki/Escape_character)                                          |
| `CHATTERBOX_ESCAPE_NODE_TAGS`             | `true`                          | Whether node metadata tags are [escaped](https://en.wikipedia.org/wiki/Escape_character)                                          |
| `CHATTERBOX_ESCAPE_CONTENT`               | `true`                          | Whether content strings are [escaped](https://en.wikipedia.org/wiki/Escape_character)                                             |
| `CHATTERBOX_ESCAPE_EXPRESSION_STRINGS`    | `false`                         | Whether expression strings are [escaped](https://en.wikipedia.org/wiki/Escape_character)                                          |
| `CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY`  | `""`                            | Directory inside Included Files that holds all external `.yarn` files. Use an empty string for the root of Included Files         |
| **Advanced Features**                     |                                 |                                                                                                                                   |
| `CHATTERBOX_INDENT_TAB_SIZE`              | `4`                             | Size of tabs for YarnScript input                                                                                                 |
| `CHATTERBOX_FILENAME_SEPARATOR`           | `":"`                           | Separator to use to concatenate filenames to node names, used to reference nodes in other source files                            |
| `CHATTERBOX_ERROR_NONSTANDARD_SYNTAX`     | `true`                          | Whether to throw an error when using a reasonable, though technically incorrect, syntax e.g. `<<end if>>` or `<<elseif>>`         |

`CHATTERBOX_DIRECTION_MODE` should be either 0, 1, or 2:

0. Pass YarnScript directions as a raw string to a function, defined by `CHATTERBOX_DIRECTION_FUNCTION`
1. Treat directions as expressions
2. Treat directions as they were in version 1 (Python-esque function calls)

&nbsp;

---

### `ChatterboxLoadFromFile(filename, [aliasName])`

_Returns:_ N/A (`undefined`)

| Name          | Datatype | Purpose                                                                                         |
| ------------- | -------- | ----------------------------------------------------------------------------------------------- |
| `filename`    | string   | Name of the file to add as a [source file](concept-source-files)                                |
| `[aliasName]` | string   | Optional name to use when referencing this file. If not specified, the filename is used instead |

If you use this function to reload a file (i.e. using the same filename as an existing [source file](concept-source-files)) then all in-progress [chatterboxes](concept-chatterboxes) that were using the previous [source file](concept-source-files) will be invalidated and will need to be restarted.

&nbsp;

---

### `ChatterboxLoadFromString(filename, string)`

_Returns:_ N/A (`undefined`)

| Name       | Datatype | Purpose                                                  |
| ---------- | -------- | -------------------------------------------------------- |
| `filename` | string   | Name to use to reference the buffer                      |
| `string`   | string   | String to parse as a [source file](concept-source-files) |

Loads a string as a source file, emulating the [`ChatterboxLoadFromFile()`](reference-configuration#chatterboxloadfromfilefilename-aliasname). The string should be formatted as a `.yarn` file. See the [Source Files](concept-source-files) pages for more information.

If you use this function to reload a file (i.e. load a buffer using the same filename as an existing [source file](concept-source-files)) then all in-progress [chatterboxes](concept-chatterboxes) that were using the previous [source file](concept-source-files) will be invalidated and will need to be restarted.

&nbsp;

---

### `ChatterboxLoadFromBuffer(filename, buffer)`

_Returns:_ N/A (`undefined`)

| Name       | Datatype                                                                                 | Purpose                                                |
| ---------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `filename` | string                                                                                   | Name to use to reference the buffer                    |
| `buffer`   | [buffer](https://manual.yoyogames.com/Additional_Information/Guide_To_Using_Buffers.htm) | Buffer to use as a [source file](concept-source-files) |

Loads a buffer as a source file, emulating the [`ChatterboxLoadFromFile()`](reference-configuration#chatterboxloadfromfilefilename-aliasname). The buffer should contain a single string that is formatted as a .yarn file. See the [Source Files](concept-source-files) pages for more information.

If you use this function to reload a file (i.e. load a buffer using the same filename as an existing [source file](concept-source-files)) then all in-progress [chatterboxes](concept-chatterboxes) that were using the previous [source file](concept-source-files) will be invalidated and will need to be restarted.

&nbsp;

---

### `ChatterboxUnload(filename)`

_Returns:_ N/A (`undefined`)

| Name       | Datatype | Purpose                    |
| ---------- | -------- | -------------------------- |
| `filename` | string   | Name of the file to unload |

Frees memory associated with the source. All in-progress [chatterboxes](concept-chatterboxes) that are using the given filename will be invalidated when this function is called.

&nbsp;

---

### `ChatterboxIsLoaded(filename)`

_Returns:_ Boolean, if the given file has been loaded as a [source file](concept-source-files)

| Name       | Datatype | Purpose                   |
| ---------- | -------- | ------------------------- |
| `filename` | string   | Name of the file to check |

&nbsp;

---

### `ChatterboxAddFunction(name, function)`

_Returns:_ Boolean, whether the function was added successfully

| Name       | Datatype        | Purpose                             |
| ---------- | --------------- | ----------------------------------- |
| `name`     | string          | Function name to use in Yarn script |
| `function` | function/method | GML function to call                |

Adds a custom function that can be called by Yarn expressions.

Custom functions can return values, but they should be **numbers** or **strings**.

GML:

```gml
ChatterboxLoad("example.json");
ChatterboxAddFunction("AmIDead", am_i_dead);
```

Yarn:

```yarn
Am I dead?
<<if AmIDead("player")>>
Yup. Definitely dead.
<<else>>
No, not yet!
<<endif>>
```

This example shows how the script `am_i_dead()` is called by Chatterbox in an if statement. The value returned from `am_i_dead()` determines which text is displayed.

Parameters for custom functions executed by Yarn script should be separated by spaces. The parameters are passed into the given function as an array of values as `argument0`.

Custom functions can be added at any point but should be added before loading in any source files.

&nbsp;

---

### `ChatterboxAddFindReplace(oldString, newString)`

_Returns:_ N/A (`undefined`)

| Name        | Datatype | Purpose                                                       |
| ----------- | -------- | ------------------------------------------------------------- |
| `oldString` | string   | String to search for in a [source file](concept-source-files) |
| `newString` | string   | String that replaces all instances of the search string       |

Find-replace operations are applied to all source files on load. These operations can be defined at any point but should be added before loading in any source files.

&nbsp;

---

### `ChatterboxSourceNodeExists(sourceName, nodeTitle)`

_Returns:_ Boolean, if the given node exists in the given source

| Name         | Datatype | Purpose                        |
| ------------ | -------- | ------------------------------ |
| `sourceName` | string   | Name of the source to check in |
| `nodeTitle`  | string   | Name of the node to check for  |

&nbsp;

---

### `ChatterboxSourceNodeCount(sourceName)`

_Returns:_ Integer, the number of nodes in the source

| Name         | Datatype | Purpose                      |
| ------------ | -------- | ---------------------------- |
| `sourceName` | string   | Name of the source to target |

&nbsp;

---

### `ChatterboxSourceGetTags(sourceName)`

_Returns:_ Array, the metadata tags associated with the source

| Name         | Datatype | Purpose                      |
| ------------ | -------- | ---------------------------- |
| `sourceName` | string   | Name of the source to target |
