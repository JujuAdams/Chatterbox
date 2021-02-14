/// Returns if the given source file has been loaded
///
/// @param filename  Name of the file to check

function ChatterboxIsLoaded(_filename)
{
    return ds_map_exists(global.chatterbox_files, _filename);
}