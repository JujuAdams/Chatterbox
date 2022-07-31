# Variables Reference

&nbsp;

### `ChatterboxVariableGet(name)`

_Returns:_ The value for the given Chatterbox variable

| Name   | Datatype | Purpose                       |
| ------ | -------- | ----------------------------- |
| `name` | string   | Variable to get the value for |

If the variable hasn't been set by YarnScript, this function will return the default value set by [`ChatterboxVariableDefault()`](reference-variables#chatterboxvariabledefaultname-value).

&nbsp;

### `ChatterboxVariableSet(name, value)`

_Returns:_ N/A (`undefined`)

| Name    | Datatype | Purpose                      |
| ------- | -------- | ---------------------------- |
| `name`  | string   | Variable to set              |
| `value` | any      | Value to set the variable to |

&nbsp;

### `ChatterboxVariableDefault(name)`

_Returns:_ N/A (`undefined`)

| Name    | Datatype | Purpose                 |
| ------- | -------- | ----------------------- |
| `name`  | string   | Variable to set         |
| `value` | any      | The default vlue to set |

&nbsp;

### `ChatterboxVariablesClearVisited(node, filename)`

_Returns:_ N/A (`undefined`)

| Name       | Datatype | Purpose                                |
| ---------- | -------- | -------------------------------------- |
| `node`     | string   | Node to "unvisit"                      |
| `filename` | string   | Filename that the node can be found in |

Clears the visited state, as returned by `visited()`, for the given node found in the given file.

&nbsp;

### `ChatterboxVariablesClearVisitedAll()`

_Returns:_ N/A (`undefined`)

| Name | Datatype | Purpose |
| ---- | -------- | ------- |
| N/A  |          |         |

Clears the visited state, as returned by `visited()`, for all nodes across all files.

&nbsp;

### `ChatterboxVariablesResetAll()`

_Returns:_ N/A (`undefined`)

| Name | Datatype | Purpose |
| ---- | -------- | ------- |
| N/A  |          |         |

Resets all variables (including `visited()` state) to their default values, as defined by `ChatterboxVariableDefault()` or `<<declare>>`.

&nbsp;

### `ChatterboxVariablesExport()`

_Returns:_ String, a JSON string that contains all Chatterbox variables and their values

| Name | Datatype | Purpose |
| ---- | -------- | ------- |
| N/A  |          |         |

The returned string also contains data on what nodes have been visited.

&nbsp;

### `ChatterboxVariablesImport(string)`

_Returns:_ N/A (`undefined`)

| Name     | Datatype | Purpose                                                                                                              |
| -------- | -------- | -------------------------------------------------------------------------------------------------------------------- |
| `string` | string   | JSON string to import, as exported by [`ChatterboxVariablesExport()`](reference-variables#chatterboxvariablesexport) |

&nbsp;

### `ChatterboxVariableFind(substring, mode, caseSensitive)`

_Returns:_ Array, variables names that match the given search substring and mode

| Name            | Datatype | Purpose                                               |
| --------------- | -------- | ----------------------------------------------------- |
| `substring`     | string   | Substring to search for in variable names             |
| `mode`          | integer  | See below                                             |
| `caseSensitive` | boolean  | Whether the search operation should be case sensitive |

Mode should be 0, 1, or 2:

0. Substring must be present anywhere in the variable name
1. Substring must prefix the variable name
2. Substring must suffix the variable name
