/// Unloads a source file from memory
/// 
/// @param filename

function chatterbox_unload(_file)
{
    variable_struct_set(global.chatterbox_files, _file, undefined);
}