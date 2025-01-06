// Feather disable all

/// Clears all localisation, causing Chatterbox to display text in the native language used to write
/// the source ChatterScript

function ChatterboxLocalizationClear()
{
    static _system = __ChatterboxSystem();
    
    ds_map_clear(_system.__localisationMap);
}
