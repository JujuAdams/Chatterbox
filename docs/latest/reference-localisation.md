# Localisation

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

&nbsp;

## `...LocalizationBuild()`

_Full function name:_ `ChatterboxLocalizationBuild(yarnPathArray, csvPath)`

_Returns:_ N/A (`undefined`)

|Name           |Datatype|Purpose                                               |
|---------------|--------|------------------------------------------------------|
|`yarnPathArray`|string  |Array of paths to Yarn files to build localisation for|
|`csvPath`      |string  |Path to save the resulting localisation CSV to        |

If the CSV file already exists it will be modified in place.

!> This function will modify source files on disk inside your project. Ensure you have backed up your work in source control.