// Feather disable all

/// 
///   !!! WARNING !!!
///   THIS FUNCTION WILL MODIFY SOURCE FILES ON DISK INSIDE YOUR PROJECT
///   ENSURE YOU HAVE BACKED UP YOUR WORK IN SOURCE CONTROL
/// 
/// File order:
/// [
///     <filename>,
/// ]
/// 
/// File dict:
/// {
///     <filename>: {
///         order: [
///             <node title>,
///         ],
///         nodes: {
///             <node title>: {
///                 order: [
///                     <hash>,
///                 ],
///                 strings: {
///                     <hash>: <string>,
///                 },
///             },
///         },
///     }.
/// }
/// @param chatterPathArray   Array of paths to source ChatterScript files, relative to CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY
/// @param csvOutputPath      Path to save the localisation CSV to, relative to CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY
/// @param [fileOrder]

function ChatterboxLocExportJSON(_chatter_path_array, _csv_path_array, _file_order = [])
{
    static _system = __ChatterboxSystem();
    
    var _file_dict = {};
    
    var _root_directory = ChatterboxLocGetRootDirectory();
    
    if (!is_array(_chatter_path_array)) _chatter_path_array = [_chatter_path_array];
    if (!is_array( _csv_path_array))  _csv_path_array = [ _csv_path_array];
    
    var _count = array_length(_chatter_path_array);
    var _i = 0;
    repeat(_count)
    {
        var _local_path    = __ChatterboxReplaceBackslashes(_chatter_path_array[_i]);
        var _absolute_path = __ChatterboxReplaceBackslashes(_root_directory + _local_path);
        
        var _buffer = buffer_load(_absolute_path);
        var _source = new __ChatterboxClassSource(_local_path, _buffer, false);
        
        var _buffer_batch = new __ChatterboxBufferBatch();
        _buffer_batch.__FromBuffer(_buffer);
        
        _source.__BuildLocalisation(_file_order, _file_dict, _buffer_batch);
        
        //Save out the modified ChatterScript file
        var _buffer = _buffer_batch.__GetBuffer();
        
        var _size = buffer_get_size(_buffer);
        
        //We artificially add a null when parsing the source buffer. Let's trim off the final null when re-saving it
        if (buffer_peek(_buffer, buffer_get_size(_buffer)-1, buffer_u8) == 0x00)
        {
            --_size;
        }
        
        buffer_save_ext(_buffer, _absolute_path, 0, _size);
        _buffer_batch.__Destroy();
        
        ++_i;
    }
    
    return _file_dict;
}
