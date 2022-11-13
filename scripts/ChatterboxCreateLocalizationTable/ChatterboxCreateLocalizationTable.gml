/// @param yarnPathArray
/// @param outputPath

function ChatterboxCreateLocalizationTable(_yarn_path_array, _output_path)
{
    if (os_browser != browser_not_a_browser)
    {
        __ChatterboxError("ChatterboxCreateLocalizationTable() not available when running in a browser");
    }
    else if ((os_type != os_windows) && (os_type != os_macosx) && (os_type != os_linux))
    {
        __ChatterboxError("ChatterboxCreateLocalizationTable() only available when running on Windows, MacOS, or Linux");
    }
    else if (GM_build_type != "run")
    {
        __ChatterboxError("ChatterboxCreateLocalizationTable() only available when running from the IDE");
    }
    else
    {
        var _root_directory = filename_dir(GM_project_filename) + "/datafiles/" + global.__chatterboxDirectory;
        
        if (!directory_exists(_root_directory))
        {
            __ChatterboxError("Could not find \"", _root_directory, "\"\nPlease check the file system sandbox is disabled");
        }
        
        if (!is_array(_yarn_path_array)) _yarn_path_array = [_yarn_path_array];
        
        var _count = array_length(_yarn_path_array);
        
        var _loc_hash_dict  = {};
        var _loc_hash_order = [];
        
        var _i = 0;
        repeat(_count)
        {
            var _local_path = _yarn_path_array[_i];
            var _absolute_path = _root_directory + _local_path;
            
            var _buffer = buffer_load(_absolute_path);
            var _source = new __ChatterboxClassSource(_local_path, _buffer, false);
            
            var _buffer_batch = new __ChatterboxBufferBatch();
            _buffer_batch.__FromBuffer(_buffer);
            
            var _lines_array = [];
            _source.__AddToLineArray(_lines_array);
            
            var _i = 0;
            repeat(array_length(_lines_array))
            {
                _lines_array[_i].__BuildLocalisation(_buffer_batch, _loc_hash_dict, _loc_hash_order);
                ++_i;
            }
            
            buffer_save(_buffer_batch.__GetBuffer(), _absolute_path);
            _buffer_batch.__Destroy();
            
            ++_i;
        }
        
        
        var _current_filename = undefined;
        var _current_node     = undefined;
        
        var _buffer = buffer_create(1024, buffer_grow, 1);
        buffer_write(_buffer, buffer_text, "File,Node,Hash,Text\n");
        
        var _func_escape_csv_string = function(_string)
        {
            return string_replace_all(_string, "\"", "\"\"");
        }
        
        var _i = 0;
        repeat(array_length(_loc_hash_order))
        {
            var _hash      = _loc_hash_order[_i];
            var _substring = _loc_hash_dict[$ _hash];
            
            if (_substring.__filename != _current_filename)
            {
                _current_filename = _substring.__filename;
                buffer_write(_buffer, buffer_text, "\"");
                buffer_write(_buffer, buffer_text, _func_escape_csv_string(_current_filename));
                buffer_write(_buffer, buffer_text, "\",,,\n");
            }
            
            if (_substring.__node != _current_node)
            {
                _current_node = _substring.__node;
                buffer_write(_buffer, buffer_text, ",\"");
                buffer_write(_buffer, buffer_text, _func_escape_csv_string(_current_node));
                buffer_write(_buffer, buffer_text, "\",,\n");
            }
            
            buffer_write(_buffer, buffer_text, ",,\"#");
            buffer_write(_buffer, buffer_text, _hash);
            buffer_write(_buffer, buffer_text, "\",\"");
            buffer_write(_buffer, buffer_text, _func_escape_csv_string(_substring.text));
            buffer_write(_buffer, buffer_text, "\"\n");
            
            ++_i;
        }
        
        buffer_save_ext(_buffer, _root_directory + _output_path, 0, buffer_tell(_buffer));
    }
}