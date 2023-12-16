// Feather disable all
/// Returns if the given source file has been loaded
///
/// @param aliasName  Name of the file to check

function ChatterboxIsLoaded(_aliasName)
{
    return ds_map_exists(global.chatterboxFiles, __ChatterboxReplaceBackslashes(_aliasName));
}
