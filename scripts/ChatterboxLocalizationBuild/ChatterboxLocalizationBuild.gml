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

function ChatterboxLocalizationBuild(_yarn_path_array, _csv_output_path)
{
    if (!CHATTERBOX_LOCALIZATION_ACKNOWLEDGE_WARNING)
    {
        __ChatterboxError("THIS FUNCTION WILL MODIFY SOURCE FILES ON DISK INSIDE YOUR PROJECT\nENSURE YOU HAVE BACKED UP YOUR WORK IN SOURCE CONTROL\n \nSet CHATTERBOX_LOCALIZATION_ACKNOWLEDGE_WARNING to <false> to turn off this warning");
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
    else
    {
        var _root_directory = filename_dir(GM_project_filename) + "/datafiles/" + global.__chatterboxDirectory;
        
        if (!directory_exists(_root_directory))
        {
            __ChatterboxError("Could not find \"", _root_directory, "\"\nPlease check the file system sandbox is disabled");
        }
        
        if (!is_array(_yarn_path_array)) _yarn_path_array = [_yarn_path_array];
        
        var _output_buffer = buffer_create(1024, buffer_grow, 1);
        buffer_write(_output_buffer, buffer_text, "File,Node,Hash,Text\n");
        
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
            
            _source.__BuildLocalisation(_output_buffer, _buffer_batch);
            
            //Save out the modified YarnScript file
            buffer_save(_buffer_batch.__GetBuffer(), _absolute_path);
            _buffer_batch.__Destroy();
            
            ++_i;
        }
        
        buffer_save_ext(_output_buffer, _root_directory + _csv_output_path, 0, buffer_tell(_output_buffer));
        buffer_delete(_output_buffer);
    }
}