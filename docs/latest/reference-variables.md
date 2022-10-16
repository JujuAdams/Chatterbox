# Variables Reference

&nbsp;

### `ChatterboxVariableDefault(name)`

_Returns:_ N/A (`undefined`)

|Name   |Datatype|Purpose                |
|-------|--------|-----------------------|
|`name` |string  |Variable to set        |
|`value`|any     |The default vlue to set|

This function sets the default value for a Chatterbox variable. This is equivalent to using the `<<declare>>` action in YarnScript. Chatterbox variables must be strings, booleans, or numbers.

?> Whilst Chatterbox and YarnScript don't require any particular naming convention, we encourage the use of `camelCase` for variable names.

&nbsp;

### `ChatterboxVariableGet(name)`

_Returns:_ The value for the given Chatterbox variable

|Name  |Datatype|Purpose                      |
|------|--------|-----------------------------|
|`name`|string  |Variable to get the value for|

Returns the value stored in a Chatterbox variable.

&nbsp;

### `ChatterboxVariableSet(name, value)`

_Returns:_ N/A (`undefined`)

|Name   |Datatype|Purpose                     |
|-------|--------|----------------------------|
|`name` |string  |Variable to set             |
|`value`|any     |Value to set the variable to|

Sets the value of a Chatterbox variable. Chatterbox variables must be strings, booleans, or numbers, and you cannot change the datatype of a variable once it has been declared. Additionally, Chatterbox constants cannot have their value changed (see below).

?> Whilst Chatterbox and YarnScript don't require any particular naming convention, we encourage the use of `camelCase` for variable names.

&nbsp;

### `ChatterboxVariableSetConstant(name, value)`

_Returns:_ N/A (`undefined`)

|Name   |Datatype|Purpose                      |
|-------|--------|-----------------------------|
|`name` |string  |Variable to set as a constant|
|`value`|any     |Value to set the variable to |

Equivalent to the `<<constant>>` action in YarnScript. Setting a Chatterbox variable as a constant causes it to behave differently to a "standard" variable:

1. Constants cannot have their value set using either `ChatterboxVariableSet()` or the YarnScript `<<set>>` action.
2. Constants will not be exported or imported using `ChatterboxVariablesExport()` or `ChatterboxVariablesImport()`.

Chatterbox constants can still have their value read by `ChatterboxVariableGet()` and can be found using `ChatterboxVariableFind()`.

?> Whilst Chatterbox and YarnScript don't require any particular naming convention, we encourage the use of `SCREAMING_SNAKE_CASE` for variable names.

&nbsp;

### `ChatterboxVariableReset(name, value)`

_Returns:_ N/A (`undefined`)

|Name  |Datatype|Purpose          |
|------|--------|-----------------|
|`name`|string  |Variable to reset|

Resets the value of a Chatterbox variable to its default starting value, either set by a `<<declare>>` YarnScript action or `ChatterboxVariableDefault()`.

&nbsp;

### `ChatterboxVariablesResetAll()`

_Returns:_ N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|N/A |        |       |

Resets the value of **all** Chatterbox variables (including `visited()` state) to their default values, as defined by `ChatterboxVariableDefault()` or `<<declare>>`.

&nbsp;

### `ChatterboxVariablesExport()`

_Returns:_ String, a JSON string that contains all Chatterbox variables and their values

|Name|Datatype|Purpose|
|----|--------|-------|
|N/A |        |       |

The returned string also contains data on what nodes have been visited. This function will exclude Chatterbox constants.

&nbsp;

### `ChatterboxVariablesImport(string)`

_Returns:_ N/A (`undefined`)

|Name    |Datatype|Purpose                                                                                                             |
|--------|--------|--------------------------------------------------------------------------------------------------------------------|
|`string`|string  |JSON string to import, as exported by [`ChatterboxVariablesExport()`](reference-variables#chatterboxvariablesexport)|

This function overwrites all Chatterbox variables, excluding constants, with whatever values are found in the input JSON. If a variable is not present in the input JSON then that variable will either be reset to its default value (see `ChatterboxVariableDefault()`) or outright deleted.

&nbsp;

### `ChatterboxVariablesClearVisited(node, filename)`

_Returns:_ N/A (`undefined`)

|Name      |Datatype|Purpose                               |
|----------|--------|--------------------------------------|
|`node`    |string  |Node to "unvisit"                     |
|`filename`|string  |Filename that the node can be found in|

Clears the visited state, as returned by the YarnScript native function `visited()`, for the given node found in the given file.

&nbsp;

### `ChatterboxVariablesClearVisitedAll()`

_Returns:_ N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|N/A |        |       |

Clears the visited state, as returned by YarnScript native function `visited()`, for all nodes across all files.

&nbsp;

### `ChatterboxVariableFind(substring, mode, caseSensitive)`

_Returns:_ Array, variables names that match the given search substring and mode

|Name           |Datatype|Purpose                                              |
|---------------|--------|-----------------------------------------------------|
|`substring`    |string  |Substring to search for in variable names            |
|`mode`         |integer |See below                                            |
|`caseSensitive`|boolean |Whether the search operation should be case sensitive|

Mode should be 0, 1, or 2:

0. Substring must be present anywhere in the variable name
1. Substring must prefix the variable name
2. Substring must suffix the variable name
