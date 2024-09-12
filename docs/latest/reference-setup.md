# Setup

Functions on this page relate to setting up how Chatterbox loads and interprets source files. All functions on this page are prefixed with `Chatterbox`.

&nbsp;

## `...LoadFromFile()`

_Full function name:_ `ChatterboxLoadFromFile(filename, [aliasName])`

_Returns:_ N/A (`undefined`)

|Name         |Datatype|Purpose                                                                                        |
|-------------|--------|-----------------------------------------------------------------------------------------------|
|`filename`   |string  |Name of the file to load as a [source file](concept-source-files)                              |
|`[aliasName]`|string  |Optional name to use when referencing this file. If not specified, the filename is used instead|

If you use this function to reload a file (i.e. using the same filename as an existing [source file](concept-source-files)) then all in-progress [chatterboxes](concept-chatterboxes) that were using the previous [source file](concept-source-files) will be invalidated and will need to be restarted.

&nbsp;

## `...LoadFromString()`

_Full function name:_ `ChatterboxLoadFromString(filename, string)`

_Returns:_ N/A (`undefined`)

|Name       |Datatype|Purpose                                                                   |
|-----------|--------|--------------------------------------------------------------------------|
|`aliasName`|string  |Name to use to reference the string (the "filename" to use for the string)|
|`string`   |string  |String to parse as a [source file](concept-source-files)                  |

Loads a string as a source file, emulating the [`ChatterboxLoadFromFile()`](reference-configuration#chatterboxloadfromfilefilename-aliasname). The string should be formatted as a `.yarn` file. See the [Source Files](concept-source-files) pages for more information.

If you use this function to reload a file (i.e. load a buffer using the same filename as an existing [source file](concept-source-files)) then all in-progress [chatterboxes](concept-chatterboxes) that were using the previous [source file](concept-source-files) will be invalidated and will need to be restarted.

&nbsp;

## `...LoadFromBuffer()`

_Full function name:_ `ChatterboxLoadFromBuffer(filename, buffer)`

_Returns:_ N/A (`undefined`)

|Name       |Datatype                                                                                |Purpose                                                                   |
|-----------|----------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
|`aliasName`|string                                                                                  |Name to use to reference the buffer (the "filename" to use for the buffer)|
|`buffer`   |[buffer](https://manual.yoyogames.com/Additional_Information/Guide_To_Using_Buffers.htm)|Buffer to use as a [source file](concept-source-files)                    |

Loads a buffer as a source file, emulating the [`ChatterboxLoadFromFile()`](reference-configuration#chatterboxloadfromfilefilename-aliasname). The buffer should contain a single string that is formatted as a `.yarn` file. See the [Source Files](concept-source-files) pages for more information.

If you use this function to reload a file (i.e. load a buffer using the same filename as an existing [source file](concept-source-files)) then all in-progress [chatterboxes](concept-chatterboxes) that were using the previous [source file](concept-source-files) will be invalidated and will need to be restarted.

&nbsp;

## `...Unload()`

_Full function name:_ `ChatterboxUnload(filename)`

_Returns:_ N/A (`undefined`)

|Name      |Datatype|Purpose                   |
|----------|--------|--------------------------|
|`filename`|string  |Name of the file to unload|

Frees memory associated with the source. All in-progress [chatterboxes](concept-chatterboxes) that are using the given filename will be invalidated when this function is called.

&nbsp;

## `...IsLoaded()`

_Full function name:_ `ChatterboxIsLoaded(filename)`

_Returns:_ Boolean, if the given file has been loaded as a [source file](concept-source-files)

|Name      |Datatype|Purpose                  |
|----------|--------|-------------------------|
|`filename`|string  |Name of the file to check|

&nbsp;

## `...AddFunction()`

_Full function name:_ `ChatterboxAddFunction(name, function)`

_Returns:_ Boolean, whether the function was added successfully

|Name      |Datatype       |Purpose                           |
|----------|---------------|----------------------------------|
|`name`    |string         |Function name to use in YarnScript|
|`function`|function/method|GML function to call              |

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

Parameters for custom functions executed by YarnScript should be separated by spaces. The parameters are passed into the given function as an array of values as `argument0`.

Custom functions can be added at any point but should be added before loading in any source files.

&nbsp;

## `...AddFindReplace()`

_Full function name:_ `ChatterboxAddFindReplace(oldString, newString)`

_Returns:_ N/A (`undefined`)

|Name       |Datatype|Purpose                                                      |
|-----------|--------|-------------------------------------------------------------|
|`oldString`|string  |String to search for in a [source file](concept-source-files)|
|`newString`|string  |String that replaces all instances of the search string      |

Find-replace operations are applied to all source files on load. These operations can be defined at any point but should be added before loading in any source files.

&nbsp;

## `...NodeChangeCallback()`

_Full function name:_ `ChatterboxNodeChangeCallback(function)`

_Returns:_ N/A (`undefined`)

|Name      |Datatype|Purpose                                      |
|----------|--------|---------------------------------------------|
|`function`|function|Function to execute when moving between nodes|

Sets a callback function that is executed whenever a chatterbox changes node. The callback will be executed in the following situations:

- Jumping to a node

- Hopping to a node

- Hopping back to a node

The callback will be executed with the following arguments:

|Name     |Datatype|Purpose                           |
|---------|--------|----------------------------------|
|`oldNode`|string  |Name of the node that we have left|
|`newNode`|string  |Name of the node we have entered  |

&nbsp;

## `...SourceNodeExists()`

_Full function name:_ `ChatterboxSourceNodeExists(sourceName, nodeTitle)`

_Returns:_ Boolean, if the given node exists in the given source

|Name        |Datatype|Purpose                       |
|------------|--------|------------------------------|
|`sourceName`|string  |Name of the source to check in|
|`nodeTitle` |string  |Name of the node to check for |

&nbsp;

## `...SourceNodeCount()`

_Full function name:_ `ChatterboxSourceNodeCount(sourceName)`

_Returns:_ Integer, the number of nodes in the source

|Name        |Datatype|Purpose                     |
|------------|--------|----------------------------|
|`sourceName`|string  |Name of the source to target|

&nbsp;

## `...SourceGetTags()`

_Full function name:_ `ChatterboxSourceGetTags(sourceName)`

_Returns:_ Array, the metadata tags associated with the source

|Name        |Datatype|Purpose                     |
|------------|--------|----------------------------|
|`sourceName`|string  |Name of the source to target|

&nbsp;

## `...SourceGetNodeMetadata`

_Full function name:_ `ChatterboxSourceGetNodeMetadata(sourceName, nodeTitle)`

_Returns:_ Struct, the metadata for the node in the given source

|Name        |Datatype|Purpose                       |
|------------|--------|------------------------------|
|`sourceName`|string  |Name of the source to check in|
|`nodeTitle` |string  |Name of the node to check for |