<h1 align="center">Variables Reference</h1>

---

### `ChatterboxVariableGet(name)`

_Returns:_ The value for the given Chatterbox variable

| Name   | Datatype | Purpose                       |
| ------ | -------- | ----------------------------- |
| `name` | string   | Variable to get the value for |

&nbsp;

---

### `ChatterboxVariableSet(name, value)`

_Returns:_ N/A (`undefined`)

| Name    | Datatype | Purpose                      |
| ------- | -------- | ---------------------------- |
| `name`  | string   | Variable to set              |
| `value` | any      | Value to set the variable to |

&nbsp;

---

### `ChatterboxVariablesExport()`

_Returns:_ String, a JSON string that contains all Chatterbox variables and their values

| Name | Datatype | Purpose |
| ---- | -------- | ------- |
| N/A  |          |         |

The returned string also contains data on what nodes have been visited.

&nbsp;

---

### `ChatterboxVariablesImport(string)`

_Returns:_ N/A (`undefined`)

| Name     | Datatype | Purpose                                                                                                              |
| -------- | -------- | -------------------------------------------------------------------------------------------------------------------- |
| `string` | string   | JSON string to import, as exported by [`ChatterboxVariablesExport()`](reference-variables#chatterboxvariablesexport) |

&nbsp;

---

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
