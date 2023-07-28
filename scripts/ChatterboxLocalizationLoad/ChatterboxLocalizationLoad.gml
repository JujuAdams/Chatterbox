// Feather disable all
/// Loads a localisation CSV file created by ChatterboxLocalizationBuild()
/// Any text in the base YarnScript file that either has no line hash or whose line hash cannot
/// be found in the localisation CSV will be displayed in the native language. Only one
/// localisation file can be used at once. New localisation is applied the next time a Chatterbox
/// flow function is executed (ChatterboxContinue() etc.)
/// 
/// @param path  Path to the localisation file to use, relative to CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY

function ChatterboxLocalizationLoad(_path)
{
    ds_map_clear(global.__chatterboxLocalisationMap);
    __ChatterboxLocalizationLoadIntoMap(_path, global.__chatterboxLocalisationMap);
}
