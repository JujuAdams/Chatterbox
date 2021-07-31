# Configuration Reference

---

### `__chatterbox_config()`

*Returns:* N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

This script holds a number of macros that customise the behaviour of Chatterbox. `__chatterbox_config()` never needs to be directly called in code, but the script and the macros it contains must be present in a project for Chatterbox to work.

**You should edit this script to customise Chatterbox for your own purposes.**

&nbsp;

&nbsp;

### `chatterbox_load_from_file(filename, [aliasName])`

*Returns:* N/A (`undefined`)

|Name         |Datatype|Purpose                                                                                        |
|-------------|--------|-----------------------------------------------------------------------------------------------|
|`filename`   |string  |Name of the file to add as a [source file](concept-source-files)                                       |
|`[aliasName]`|string  |Optional name to use when referencing this file. If not specified, the filename is used instead|

If you use this function to reload a file (i.e. using the same filename as an existing [source file](concept-source-files)) then all in-progress [chatterboxes](concept-chatterboxes) that were using the previous [source file](concept-source-files) will be invalidated and will need to be restarted.

&nbsp;

&nbsp;

### `chatterbox_load_from_string(filename, string)`

*Returns:* N/A (`undefined`)

|Name      |Datatype|Purpose                                         |
|----------|--------|------------------------------------------------|
|`filename`|string  |Name to use to reference the buffer             |
|`string`  |string  |String to parse as a [source file](concept-source-files)|

Loads a string as a source file, emulating the [`chatterbox_load_from_file()`](reference-configuration#chatterbox_load_from_filefilename). The string should be formatted as either a .yarn file or a Yarn JSON. See the [Source Files](concept-source-files) pages for more information.

If you use this function to reload a file (i.e. load a buffer using the same filename as an existing [source file](concept-source-files)) then all in-progress [chatterboxes](concept-chatterboxes) that were using the previous [source file](concept-source-files) will be invalidated and will need to be restarted.

&nbsp;

&nbsp;

### `chatterbox_load_from_buffer(filename, buffer)`

*Returns:* N/A (`undefined`)

|Name      |Datatype|Purpose                            |
|----------|--------|-----------------------------------|
|`filename`|string  |Name to use to reference the buffer|
|`buffer`  |[buffer](https://docs2.yoyogames.com/source/_build/1_overview/3_additional_information/using_buffers.html)|Buffer to use as a [source file](concept-source-files)|

Loads a buffer as a source file, emulating the [`chatterbox_load_from_file()`](reference-configuration#chatterbox_load_from_filefilename). The buffer should contain a single string that is formatted as either a .yarn file or a Yarn JSON. See the [Source Files](concept-source-files) pages for more information.

If you use this function to reload a file (i.e. load a buffer using the same filename as an existing [source file](concept-source-files)) then all in-progress [chatterboxes](concept-chatterboxes) that were using the previous [source file](concept-source-files) will be invalidated and will need to be restarted.

&nbsp;

&nbsp;

### `chatterbox_unload(filename)`

*Returns:* N/A (`undefined`)

|Name      |Datatype|Purpose                   |
|----------|--------|--------------------------|
|`filename`|string  |Name of the file to unload|

All in-progress [chatterboxes](concept-chatterboxes) that are using the given filename will be invalidated when this function is called.

&nbsp;

&nbsp;

### `chatterbox_is_loaded(filename)`

*Returns:* Boolean, if the given file has been loaded as a [source file](concept-source-files)

|Name      |Datatype|Purpose                  |
|----------|--------|-------------------------|
|`filename`|string  |Name of the file to check|

&nbsp;

&nbsp;

### `chatterbox_add_function(name, function)`

*Returns:* Boolean, whether the function was added successfully

|Name      |Datatype       |Purpose                            |
|----------|---------------|-----------------------------------|
|`name`    |string         |Function name to use in Yarn script|
|`function`|function/method|GML function to call               |

Adds a custom function that can be called by Yarn expressions.

Custom functions can return values, but they should be **numbers** or **strings**.

GML:
```
chatterbox_load("example.json");
chatterbox_add_function("AmIDead", am_i_dead);
```

Yarn:
```
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

&nbsp;

### `chatterbox_add_findreplace(oldString, newString)`

*Returns:* N/A (`undefined`)

|Name       |Datatype|Purpose                                                |
|-----------|--------|-------------------------------------------------------|
|`oldString`|string  |String to search for in a [source file](concept-source-files)  |
|`newString`|string  |String that replaces all instances of the search string|

Findreplace operations can be defined at any point but should be added before loading in any source files.