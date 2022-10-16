# Chatterboxes Reference

&nbsp;

### `ChatterboxCreate([filename], [singletonText]), [localScope])`

_Returns:_ A new [chatterbox](concept-chatterboxes)

|Name             |Datatype       |Purpose                                                                                                                                                                                                                                                                          |
|-----------------|---------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`[filename]`     |string         |[Source file](concept-source-files) to target. If not specified, the default [source file](concept-source-files) will be used (the first [source file](concept-source-files) that was [loaded](reference-configuration#chatterboxloadfromfilefilename-aliasname) into Chatterbox)|
|`[singletonText]`|boolean        |Whether content is revealed one line at a time (see below). If not specified, [`CHATTERBOX_DEFAULT_SINGLETON`](reference-configuration#__chatterboxconfig) is used instead                                                                                                       |
|`[localScope]`   |instance/struct|Scope to execute Yarn function calls in                                                                                                                                                                                                                                          |

If `singletonText` is set to `true` then dialogue will be outputted one line at a time. This is typical behaviour for RPGs like Pokémon or Final Fantasy where characters talk one at a time. Only one piece of dialogue will be shown at a time.

However, if `singletonText` is set to `false` then dialogue will be outputted multiple lines at a time. More modern narrative games, especially those by Inkle or Failbetter, tend to show larger blocks of text. Content will be stacked up until Chatterbox reaches a command that requires user input: a shortcut, an option, or a `<<stop>>` or `<<wait>>` command.

&nbsp;

---

### `IsChatterbox(value)`

_Returns:_ Boolean, whether the given value is a [chatterbox](concept-chatterboxes)

|Name   |Datatype|Purpose           |
|-------|--------|------------------|
|`value`|any     |The value to check|
