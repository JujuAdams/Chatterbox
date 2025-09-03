// Feather disable all

/// Parses an array of ChatternScript files stored in your project's Included Filess directory and
/// creates a CSV that contains all strings in those source files. The ChatterScript files are
/// modified by this function such that they link up to the CSV. You should then create a copy of
/// the CSV file for each language you're localising into and load then using
/// `ChatterboxLocalizationLoad()` when you wish to localise Chatterbox text into a different
/// language.
/// 
///   !!! WARNING !!!
///   THIS FUNCTION WILL MODIFY SOURCE FILES ON DISK INSIDE YOUR PROJECT
///   ENSURE YOU HAVE BACKED UP YOUR WORK IN SOURCE CONTROL
/// 
/// @param chatterPathArray   Array of paths to source ChatterScript files, relative to CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY
/// @param csvOutputPath      Path to save the localisation CSV to, relative to CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY

function ChatterboxLocalizationBuild(_chatter_path_array, _csv_path_array)
{
    static _system = __ChatterboxSystem();
    
    var _root_directory = __ChatterboxLocGetRootDirectory();
    var _data = ChatterboxLocalizationExportData(_chatter_path_array);
    
    if (!is_array( _csv_path_array))  _csv_path_array = [ _csv_path_array];
    
    //Go through each CSV file and merge in changes
    var _csv_loc_map = ds_map_create();
    var _output_buffer = buffer_create(1024, buffer_grow, 1);
    
    var _c = 0;
    repeat(array_length(_csv_path_array))
    {
        buffer_seek(_output_buffer, buffer_seek_start, 0);
        buffer_write(_output_buffer, buffer_text, "Status,File,Node,Line ID,Hash,Text\n");
        
        var _local_path    = __ChatterboxReplaceBackslashes(_csv_path_array[_c]);
        var _absolute_path = __ChatterboxReplaceBackslashes(_root_directory + _local_path);
        
        ds_map_clear(_csv_loc_map);
        __ChatterboxLocalizationLoadIntoMap(_absolute_path, _csv_loc_map, true);
        
        var _f = 0;
        repeat(array_length(_data))
        {
            var _file_struct = _data[_f];
            var _filename    = _file_struct.filename;
            var _node_array  = _file_struct.nodes;
            
            buffer_write(_output_buffer, buffer_text, ",\"");
            buffer_write(_output_buffer, buffer_text, __ChatterboxEscapeForCSV(_filename));
            buffer_write(_output_buffer, buffer_text, "\",,,,\n");
            
            var _n = 0;
            repeat(array_length(_node_array))
            {
                var _node_struct  = _node_array[_n];
                var _node_title   = _node_struct.title;
                var _string_array = _node_struct.strings;
                
                buffer_write(_output_buffer, buffer_text, ",,\"");
                buffer_write(_output_buffer, buffer_text, __ChatterboxEscapeForCSV(_node_title));
                buffer_write(_output_buffer, buffer_text, "\",,,\n");
                
                var _s = 0;
                repeat(array_length(_string_array))
                {
                    var _string_struct = _string_array[_s];
                    var _line_id       = _string_struct.line_id;
                    var _new_text      = _string_struct.content;
                    
                    var _new_hash = "#" + string_copy(md5_string_unicode(_new_text), 1, __CHATTERBOX_TEXT_HASH_LENGTH);
                    
                    var _full_key = _filename + ":" + _node_title + ":#" + _line_id;
                    var _old_text = _csv_loc_map[? _full_key];
                    var _old_hash = _csv_loc_map[? _full_key + ":hash"];
                    
                    var _status = "";
                    var _write_text = _new_text;
                    
                    if (_old_hash == undefined)
                    {
                        //New string
                        var _status = "NEW";
                    }
                    else if (_old_hash != _new_hash)
                    {
                        //Text changed
                        var _status = "CHANGED";
                    }
                    else
                    {
                        //No change
                        _write_text = _old_text;
                    }
                    
                    buffer_write(_output_buffer, buffer_text, _status);
                    buffer_write(_output_buffer, buffer_text, ",,,\"#");
                    buffer_write(_output_buffer, buffer_text, _line_id);
                    buffer_write(_output_buffer, buffer_text, "\",\"");
                    buffer_write(_output_buffer, buffer_text, _new_hash);
                    buffer_write(_output_buffer, buffer_text, "\",\"");
                    buffer_write(_output_buffer, buffer_text, __ChatterboxEscapeForCSV(_write_text));
                    buffer_write(_output_buffer, buffer_text, "\"\n");
                    
                    ++_s;
                }
                
                ++_n;
            }
            
            ++_f;
        }
        
        buffer_save_ext(_output_buffer, _absolute_path, 0, buffer_tell(_output_buffer));
        
        ++_c;
    }
    
    buffer_delete(_output_buffer);
    ds_map_destroy(_csv_loc_map);
}
