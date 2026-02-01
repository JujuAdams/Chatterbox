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

|Name  |Datatype|Purpose                                                                                        |
|------|--------|-----------------------------------------------------------------------------------------------|
|`path`|string  |Path to the localisation CSV file to load, relative to `CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY`|

Loads a localisation CSV file created by `ChatterboxLocalizationBuild()`. Any text in the base ChatterScript file that either has no line hash or whose line hash cannot be found in the localisation CSV will be displayed in the native language. Only one localisation file can be used at once. New localisation is applied the next time a Chatterbox flow function is executed (`ChatterboxContinue()` etc.).

&nbsp;

## `...LocalizationClear()`

_Full function name:_ `ChatterboxLocalizationClear()`

_Returns:_ N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|N/A |        |       |

Clears all localisation, causing Chatterbox to display text in the native language used to write the source ChatterScript.

&nbsp;

## `...LocalizationExportData()`

_Full function name:_ `ChatterboxLocalizationExportData(chatterPathArray)`

_Returns:_ N/A (`undefined`)

|Name              |Datatype        |Purpose                                                                                           |
|------------------|----------------|--------------------------------------------------------------------------------------------------|
|`chatterPathArray`|array of strings|Array of paths to source ChatterScript files, relative to `CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY`|

Parses an array of ChatternScript files stored in your project's Included Filess directory and creates a struct/array data structure that contains all strings in those source files. The ChatterScript files are modified by this function such that they link up to the data structure.

!> This function will modify source files on disk inside your project. Ensure you have backed up your work in source control.

You can then save out the data (perhaps using `json_stringify()`) to a file. Translators can modify the file and the localizaed strings should then be loaded by the sister function `ChatterboxLocalizationImportData()`.

The data structure generated by this function follows the following format:

```
[
    {
        filename: <string>,
        nodes: [
            {
                title: <string>,
                strings: [
                    {
                        hash: <string>,
                        content: <string>,
                    },
                    ...
                ]
            },
            ...
        ]
   ],
   ...
]
```

&nbsp;

## `...LocalizationImportData()`

_Full function name:_ `ChatterboxLocalizationImportData(data)`

_Returns:_ N/A (`undefined`)

|Name  |Datatype    |Purpose                                                                                           |
|------|------------|--------------------------------------------------------------------------------------------------|
|`data`|array/struct|Array of paths to source ChatterScript files, relative to `CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY`|

Takes a struct/array data structure generated by `ChatterboxLocalizationExportData()` and applies it in the same manner as `ChatterboxLocalizationBuild()`. This function is provided as an alternative to CSV-based localization.

&nbsp;

## `...LocalizationGetChars()`

_Full function name:_ `ChatterboxLocalizationGetChars(path, [returnCodepoints=false])`

_Returns:_ Array, 

|Name                |Datatype|Purpose                                                                                   |
|--------------------|--------|------------------------------------------------------------------------------------------|
|`path`              |string  |Path to the localisation file to use, relative to `CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY`|
|`[returnCodepoints]`|boolean |Whether to return numeric Unicode codepoint (`true`) or character strings (`false`)       |

Returns an array of text characters (letters, numbers, symbols etc.) that are used in the target localisation CSV. This is useful for building font ranges.