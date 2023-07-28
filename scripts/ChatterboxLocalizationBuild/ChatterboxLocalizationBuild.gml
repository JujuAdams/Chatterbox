// Feather disable all
/// Parses an array of YarnScript files stored in your project's Included Filess directory and
/// creates a CSV that contains all strings in those source files. The YarnScript files are modified
/// by this function such that they link up to the CSV. You should then create a copy of the CSV
/// file for each language you're localising into and load then using ChatterboxLocalizationLoad()
/// when you wish to localise Chatterbox text into a different language.
/// 
///   !!! WARNING !!!
///   THIS FUNCTION WILL MODIFY SOURCE FILES ON DISK INSIDE YOUR PROJECT
///   ENSURE YOU HAVE BACKED UP YOUR WORK IN SOURCE CONTROL
/// 
/// @param yarnPathArray   Array of paths to source YarnScript files, relative to CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY
/// @param csvOutputPath   Path to save the localisation CSV to, relative to CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY

function ChatterboxLocalizationBuild(_yarn_path_array, _csv_path_array)
{
    if (!CHATTERBOX_LOCALIZATION_ACKNOWLEDGE_WARNING)
    {
        __ChatterboxError("THIS FUNCTION WILL MODIFY SOURCE FILES ON DISK INSIDE YOUR PROJECT\nENSURE YOU HAVE BACKED UP YOUR WORK IN SOURCE CONTROL\n \nSet CHATTERBOX_LOCALIZATION_ACKNOWLEDGE_WARNING to <true> to turn off this warning");
    }
    else if (os_browser != browser_not_a_browser)
    {
        __ChatterboxError("ChatterboxLocalizationBuild() not available when running in a browser");
    }
    else if ((os_type != os_windows) && (os_type != os_macosx) && (os_type != os_linux))
    {
        __ChatterboxError("ChatterboxLocalizationBuild() only available when running on Windows, MacOS, or Linux");
    }
    else if (GM_build_type != "run")
    {
        __ChatterboxError("ChatterboxLocalizationBuild() only available when running from the IDE");
    }
    var _root_directory = filename_dir(GM_project_filename) + "/datafiles/" + global.__chatterboxDirectory;
    
    if (!directory_exists(_root_directory))
    {
        __ChatterboxError("Could not find \"", _root_directory, "\"\nPlease check the file system sandbox is disabled");
    }
    
    if (!is_array(_yarn_path_array)) _yarn_path_array = [_yarn_path_array];
    if (!is_array( _csv_path_array))  _csv_path_array = [ _csv_path_array];
    
    var _file_order = [];
    var _file_dict  = {};
    // [
    //     <filename>,
    // ]
    // 
    // {
    //     <filename>: {
    //         order: [
    //             <node title>,
    //         ],
    //         nodes: {
    //             <node title>: {
    //                 order: [
    //                     <hash>,
    //                 ],
    //                 strings: {
    //                     <hash>: <string>,
    //                 },
    //             },
    //         },
    //     }.
    // }
    
    var _count = array_length(_yarn_path_array);
    var _i = 0;
    repeat(_count)
    {
        var _local_path = _yarn_path_array[_i];
        var _absolute_path = _root_directory + _local_path;
        
        var _buffer = buffer_load(_absolute_path);
        var _source = new __ChatterboxClassSource(_local_path, _buffer, false);
        
        var _buffer_batch = new __ChatterboxBufferBatch();
        _buffer_batch.__FromBuffer(_buffer);
        
        _source.__BuildLocalisation(_file_order, _file_dict, _buffer_batch);
        
        //Save out the modified YarnScript file
        buffer_save(_buffer_batch.__GetBuffer(), _absolute_path);
        _buffer_batch.__Destroy();
        
        ++_i;
    }
    
    //Go through each CSV file and merge in changes
    var _csv_loc_map = ds_map_create();
    var _output_buffer = buffer_create(1024, buffer_grow, 1);
    
    var _c = 0;
    repeat(array_length(_csv_path_array))
    {
        buffer_seek(_output_buffer, buffer_seek_start, 0);
        buffer_write(_output_buffer, buffer_text, "Status,File,Node,Line ID,Hash,Text\n");
        
        var _local_path = _csv_path_array[_c];
        var _absolute_path = _root_directory + _local_path;
        
        ds_map_clear(_csv_loc_map);
        __ChatterboxLocalizationLoadIntoMap(_absolute_path, _csv_loc_map, true);
        
        var _f = 0;
        repeat(array_length(_file_order))
        {
            var _filename = _file_order[_f];
            
            buffer_write(_output_buffer, buffer_text, ",\"");
            buffer_write(_output_buffer, buffer_text, __ChatterboxEscapeForCSV(_filename));
            buffer_write(_output_buffer, buffer_text, "\",,,,\n");
            
            var _file_struct = _file_dict[$ _filename];
            var _node_order = _file_struct.order;
            var _node_dict  = _file_struct.nodes;
            
            var _n = 0;
            repeat(array_length(_node_order))
            {
                var _node_title = _node_order[_n];
                
                buffer_write(_output_buffer, buffer_text, ",,\"");
                buffer_write(_output_buffer, buffer_text, __ChatterboxEscapeForCSV(_node_title));
                buffer_write(_output_buffer, buffer_text, "\",,,\n");
                
                var _node_struct = _node_dict[$ _node_title];
                var _string_order = _node_struct.order;
                var _string_dict  = _node_struct.strings;
                
                var _s = 0;
                repeat(array_length(_string_order))
                {
                    var _line_id = _string_order[_s];
                    
                    var _new_text = _string_dict[$ _line_id];
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
                    buffer_write(_output_buffer, buffer_text, _write_text);
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
