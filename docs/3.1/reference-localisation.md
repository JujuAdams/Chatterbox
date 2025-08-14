# Localisation

The functions on this page relate to the use of Chatterbox's native localisation implement. Use of these functions is purely optional and you may find using your own solution is preferable.

Chatterbox's localisation system automates a lot of the process for you. Of particular note is `LocalizationBuild()` which automatically tags every line in your ChatterScript files with metadata in the format `#line:??????` where the question marks are a unique hash that identifies a line of dialogue. Note that the hash is attached to the _line_ rather than the _text_ and the hash isn't generated based on the content of the line itself. The hash for each line of dialogue indentifies that line of dialogue and allows Chatterbox to replace the original text with new text.

`LocalizationBuild()` not only writes line metadata into ChatterScript files but also saves out a CSV file that contains all the lines of dialogue. This CSV file can have its content edited and then loaded back into the game via `ChatterboxLocalizationLoad()` using the aforementioned hashes to identify each line. You can unload the current localisation file by using `ChatterboxLocalizationClear()`. To support multiple different languages you should make many copies of the CSV file (by passing in multiple strings for `csvPathArray`) and edit one CSV for each language.

If your ChatterScript file has been edited and is now out of sync with your CSV file(s) then you can re-run `ChatterboxLocalizationBuild()` and target the localised CSV files. The function will mark any adjusted or new lines in the CSV file allowing your localisation team to update the CSV file as necessary.

&nbsp;

## `...LocalizationBuild()`

_Full function name:_ `ChatterboxLocalizationBuild(chatterPathArray, csvPathArray)`

_Returns:_ N/A (`undefined`)

|Name              |Datatype        |Purpose                                                                             |
|------------------|----------------|------------------------------------------------------------------------------------|
|`chatterPathArray`|array of strings|Array of paths to ChatterScript files to build localisation for                     |
|`csvPathArray`    |array of strings|Array of paths to save the resulting localisation CSV to e.g. for multiple languages|

Adds `#line` metadata to any unmarked lines in the ChatterScript files specified, and exports a CSV containing all text in the ChatterScript files (including previously marked lines). If the CSV file already exists it will be modified in place, noting any changed lines.

!> This function will modify the ChatterScript files on disk. Ensure you have backed up your work in source control.

&nbsp;

## `...LocalizationLoad()`

_Full function name:_ `ChatterboxLocalizationLoad(path)`

_Returns:_ N/A (`undefined`)

|Name  |Datatype|Purpose                                  |
|------|--------|-----------------------------------------|
|`path`|string  |Path to the localisation CSV file to load|

&nbsp;

## `...LocalizationClear()`

_Full function name:_ `ChatterboxLocalizationClear()`

_Returns:_ N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|N/A |        |       |
