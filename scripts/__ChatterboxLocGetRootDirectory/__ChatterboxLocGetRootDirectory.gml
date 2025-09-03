function __ChatterboxLocGetRootDirectory()
{
    static _system = __ChatterboxSystem();
    
    if (!CHATTERBOX_LOCALIZATION_ACKNOWLEDGE_WARNING)
    {
        __ChatterboxError("THIS FUNCTION WILL MODIFY SOURCE FILES ON DISK INSIDE YOUR PROJECT\nENSURE YOU HAVE BACKED UP YOUR WORK IN SOURCE CONTROL\n \nSet CHATTERBOX_LOCALIZATION_ACKNOWLEDGE_WARNING to <true> to turn off this warning");
    }
    else if (os_browser != browser_not_a_browser)
    {
        __ChatterboxError("ChatterboxLocAdv() not available when running in a browser");
    }
    else if ((os_type != os_windows) && (os_type != os_macosx) && (os_type != os_linux))
    {
        __ChatterboxError("ChatterboxLocAdv() only available when running on Windows, MacOS, or Linux");
    }
    else if (not CHATTERBOX_RUNNING_FROM_IDE)
    {
        __ChatterboxError("ChatterboxLocAdv() only available when running from the IDE");
    }
    
    var _root_directory = filename_dir(GM_project_filename) + "/datafiles/" + _system.__directory;
    
    if (!directory_exists(_root_directory))
    {
        __ChatterboxError("Could not find \"", _root_directory, "\"\nPlease check the file system sandbox is disabled");
    }
    
    return _root_directory;
}