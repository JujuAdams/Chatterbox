// Feather disable all
/// Returns if the given source file has been loaded
///
/// @param aliasName  Name of the file to check

function ChatterboxIsLoaded(_aliasName)
{
    static _system = __ChatterboxSystem();
    
    return ds_map_exists(_system.__files, __ChatterboxReplaceBackslashes(_aliasName));
}
