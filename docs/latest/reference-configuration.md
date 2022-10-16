# Configuration Reference

The `__ChatterboxConfig()` script contains a multitude of macros that you can use to customise the behaviour of Chatterbox. `__ChatterboxConfig()` never needs to be directly called in code, but the script and the macros it contains must be present in a project for Chatterbox to work.

!> You should edit `__ChatterboxConfig()` to customise Chatterbox for your own purposes.

&nbsp;

|Macro                                    |Typical value                  |Purpose                                                                                                                                                               |
|-----------------------------------------|-------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`CHATTERBOX_DEFAULT_SINGLETON`           |`true`                         |Whether chatterboxes should default to being singleton                                                                                                                |
|`CHATTERBOX_ALLOW_SCRIPTS`               |`true`                         |Whether to allow scripts to be added as Chatterbox functions                                                                                                          |
|`CHATTERBOX_FUNCTION_ARRAY_ARGUMENTS`    |`true`                         |Whether to execute callbacks with an array of arguments. Setting this to `false` will execute callbacks with individual arguments                                     |
|`CHATTERBOX_SINGLETON_WAIT_BEFORE_OPTION`|`false`                        |Whether a chatterbox will enter into a waiting state before options are enumerated                                                                                    |
|`CHATTERBOX_WAIT_BEFORE_STOP`            |`true`                         |Whether a chatterbox will enter into a waiting state before a chatterbox goes into a `<<stop>>` state                                                                 |
|`CHATTERBOX_SHOW_REJECTED_OPTIONS`       |`true`                         |Whether to expose options whose conditional check has failed. Setting this to `false` will never expose rejected options                                              |
|`CHATTERBOX_DECLARE_ON_COMPILE`          |`true`                         |Whether to declare variables when Chatterbox script is compiled. Set to `false` for legacy (2.1 and earlier) behaviour                                                |
|`CHATTERBOX_END_OF_NODE_HOPBACK`         |`true`                         |Whether nodes without an explicit `<<stop>>` or `<<hopback>>` command at the end should default to `<<hopback>>`. Legacy behaviour (pre-2.7) is to set this to `false`|
|`CHATTERBOX_DIRECTION_MODE`              |`0`                            |See below                                                                                                                                                             |
|`CHATTERBOX_DIRECTION_FUNCTION`          |`TestCaseDirectionFunction`    |Function to use to handle directions. This only applies in mode 0 (see below)                                                                                         |
|`CHATTERBOX_ESCAPE_FILE_TAGS`            |`true`                         |Whether file metadata tags are [escaped](https://en.wikipedia.org/wiki/Escape_character)                                                                              |
|`CHATTERBOX_ESCAPE_NODE_TAGS`            |`true`                         |Whether node metadata tags are [escaped](https://en.wikipedia.org/wiki/Escape_character)                                                                              |
|`CHATTERBOX_ESCAPE_CONTENT`              |`true`                         |Whether content strings are [escaped](https://en.wikipedia.org/wiki/Escape_character)                                                                                 |
|`CHATTERBOX_ESCAPE_EXPRESSION_STRINGS`   |`false`                        |Whether expression strings are [escaped](https://en.wikipedia.org/wiki/Escape_character)                                                                              |
|`CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY` |`""`                           |Directory inside Included Files that holds all external `.yarn` files. Use an empty string for the root of Included Files                                             |
|**Advanced Features**                    |                               |                                                                                                                                                                      |
|`CHATTERBOX_INDENT_TAB_SIZE`             |`4`                            |Size of tabs for YarnScript input                                                                                                                                     |
|`CHATTERBOX_FILENAME_SEPARATOR`          |`":"`                          |Separator to use to concatenate filenames to node names, used to reference nodes in other source files                                                                |
|`CHATTERBOX_ERROR_NONSTANDARD_SYNTAX`    |`true`                         |Whether to throw an error when using a reasonable, though technically incorrect, syntax e.g. `<<end if>>` or `<<elseif>>`                                             |

`CHATTERBOX_DIRECTION_MODE` should be either 0, 1, or 2:

0. Pass YarnScript directions as a raw string to a function, defined by `CHATTERBOX_DIRECTION_FUNCTION`
1. Treat directions as expressions
2. Treat directions as they were in version 1 (Python-esque function calls)