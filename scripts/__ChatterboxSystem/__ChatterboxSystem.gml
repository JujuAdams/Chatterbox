// Feather disable all

__ChatterboxSystem();
function __ChatterboxSystem()
{
    static _system = undefined;
    if (_system != undefined) return _system;
    
    _system = {};
    with(_system)
    {
        __ChatterboxTrace("Welcome to Chatterbox by Juju Adams! This is version " + __CHATTERBOX_VERSION + ", " + __CHATTERBOX_DATE);
        
        var _chatterboxDirectory = CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY;
        
        if (__CHATTERBOX_ON_MOBILE)
        {
            if (_chatterboxDirectory != "")
            {
                __ChatterboxError("GameMaker's Included Files work a bit strangely on iOS and Android.\nPlease use an empty string for CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY and place fonts in the root of Included Files");
                exit;
            }
        }
        
        if (_chatterboxDirectory != "")
        {
            //Fix the font directory name if it's weird
            var _char = string_char_at(_chatterboxDirectory, string_length(_chatterboxDirectory));
            if (_char != "\\") && (_char != "/") _chatterboxDirectory += "\\";
        }
        
        if (!__CHATTERBOX_ON_WEB)
        {
            //Check if the directory exists
            if ((_chatterboxDirectory != "") && !directory_exists(_chatterboxDirectory))
            {
                __ChatterboxTrace("Warning! Font directory \"" + string(_chatterboxDirectory) + "\" could not be found in \"" + game_save_id + "\"!");
            }
        }
        
        //Verify CHATTERBOX_ACTION_FUNCTION has been set to a valid global function
        try
        {
            if (script_exists(CHATTERBOX_ACTION_FUNCTION) || is_method(CHATTERBOX_ACTION_FUNCTION))
            {
                if (__CHATTERBOX_DEBUG_INIT) __ChatterboxTrace("CHATTERBOX_ACTION_FUNCTION is valid");
            }
        }
        catch(_error)
        {
            if (CHATTERBOX_ACTION_MODE == 0)
            {
                __ChatterboxError("CHATTERBOX_ACTION_FUNCTION is not a valid global function\n\n(This is only a requirement if CHATTERBOX_ACTION_MODE == 0)");
            }
            else
            {
                if (__CHATTERBOX_DEBUG_INIT) __ChatterboxTrace("CHATTERBOX_ACTION_FUNCTION is invalid, but CHATTERBOX_ACTION_MODE = ", CHATTERBOX_ACTION_MODE);
            }
        }
        
        //Declare global variables
        global.__chatterboxDirectory            = _chatterboxDirectory;
        
        global.__chatterboxVariablesMap         = ds_map_create();
        global.__chatterboxVariablesList        = ds_list_create();
        global.__chatterboxVariablesSetCallback = undefined;
        global.__chatterboxConstantsMap         = ds_map_create();
        global.__chatterboxConstantsList        = ds_list_create();
        global.__chatterboxDefaultVariablesMap  = ds_map_create();
        global.__chatterboxDeclaredVariablesMap = ds_map_create();
        
        global.chatterboxFiles                  = ds_map_create();
        global.__chatterboxDefaultFile          = "";
        global.__chatterboxIndentSize           = 0;
        global.__chatterboxFindReplaceOldString = ds_list_create();
        global.__chatterboxFindReplaceNewString = ds_list_create();
        global.__chatterboxVMInstanceStack      = [];
        global.__chatterboxVMWait               = false;
        global.__chatterboxVMForceWait          = false;
        global.__chatterboxVMFastForward        = false;
        global.__chatterboxCurrent              = undefined;
        global.__chatterboxLocalisationMap      = ds_map_create();
        if (!variable_global_exists("__chatterbox_functions")) global.__chatterboxFunctions = ds_map_create();
        
        //Big ol' list of operators. Operators at the top at processed first
        //Not included here are negative signs, negation (! / NOT), and parentheses - these are handled separately
        global.__chatterboxOpList = ds_list_create();
        if (CHATTERBOX_LEGACY_WEIRD_OPERATOR_PRECEDENCE)
        {
            ds_list_add(global.__chatterboxOpList, "+" );
            ds_list_add(global.__chatterboxOpList, "-" );
            ds_list_add(global.__chatterboxOpList, "*" );
            ds_list_add(global.__chatterboxOpList, "/" );
            ds_list_add(global.__chatterboxOpList, "==");
            ds_list_add(global.__chatterboxOpList, "!=");
            ds_list_add(global.__chatterboxOpList, ">" );
            ds_list_add(global.__chatterboxOpList, "<" );
            ds_list_add(global.__chatterboxOpList, ">=");
            ds_list_add(global.__chatterboxOpList, "<=");
            ds_list_add(global.__chatterboxOpList, "||");
            ds_list_add(global.__chatterboxOpList, "&&");
            ds_list_add(global.__chatterboxOpList, "+=");
            ds_list_add(global.__chatterboxOpList, "-=");
            ds_list_add(global.__chatterboxOpList, "*=");
            ds_list_add(global.__chatterboxOpList, "/=");
            ds_list_add(global.__chatterboxOpList, "=" );
        }
        else
        {
            ds_list_add(global.__chatterboxOpList, "*" );
            ds_list_add(global.__chatterboxOpList, "/" );
            ds_list_add(global.__chatterboxOpList, "-" );
            ds_list_add(global.__chatterboxOpList, "+" );
            ds_list_add(global.__chatterboxOpList, ">" );
            ds_list_add(global.__chatterboxOpList, "<" );
            ds_list_add(global.__chatterboxOpList, ">=");
            ds_list_add(global.__chatterboxOpList, "<=");
            ds_list_add(global.__chatterboxOpList, "==");
            ds_list_add(global.__chatterboxOpList, "!=");
            ds_list_add(global.__chatterboxOpList, "&&");
            ds_list_add(global.__chatterboxOpList, "||");
            ds_list_add(global.__chatterboxOpList, "+=");
            ds_list_add(global.__chatterboxOpList, "-=");
            ds_list_add(global.__chatterboxOpList, "*=");
            ds_list_add(global.__chatterboxOpList, "/=");
            ds_list_add(global.__chatterboxOpList, "=" );
        }
    }
    
    return _system;
}