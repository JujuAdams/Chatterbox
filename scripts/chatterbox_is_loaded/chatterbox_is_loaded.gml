/// Returns <true> if the given source file has been loaded
/// 
/// @param filename

function chatterbox_is_loaded(_file)
{
    return (instanceof(variable_struct_get(global.chatterbox_files, _file)) == "__chatterbox_class_file");
}