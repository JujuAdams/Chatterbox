// Feather disable all
/// Clears all localisation, causing Chatterbox to display text in the native language used to write
/// the source YarnScript

function ChatterboxLocalizationClear()
{
    ds_map_clear(global.__chatterboxLocalisationMap);
}
