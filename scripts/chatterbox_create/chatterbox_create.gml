/// @param [nodeTitle]
/// @param [filename]
/// @param [originX]
/// @param [originY]

var _node_title = ((argument_count > 0)                              )? argument[0] : undefined;
var _filename   = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : global.__chatterbox_default_file;
var _origin_x   = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : 0;
var _origin_y   = ((argument_count > 3) && (argument[3] != undefined))? argument[3] : 0;


if (!is_string(_filename))
{
    show_error("Chatterbox:\nYarn .json filenames must be strings (Got \"" + string(_filename) + "\")\n ", false);
    return undefined;
}

if (!ds_map_exists(global.__chatterbox_file_data, _filename))
{
    show_error("Chatterbox:\nCannot find Yarn .json \"" + _filename + "\"\n ", false);
    return undefined;
}



//Create the Chatterbox data structure
var _list = ds_list_create();

_list[| __CHATTERBOX.__SECTION0   ] = "-- Parameters --";
_list[| __CHATTERBOX.FILENAME     ] = _filename;
_list[| __CHATTERBOX.TITLE        ] = _node_title;
_list[| __CHATTERBOX.ORIGIN_X     ] = _origin_x;
_list[| __CHATTERBOX.ORIGIN_Y     ] = _origin_y;

_list[| __CHATTERBOX.__SECTION1   ] = "-- State --";
_list[| __CHATTERBOX.HIGHLIGHTED  ] = 0;
_list[| __CHATTERBOX.INITIALISED  ] = false;
_list[| __CHATTERBOX.VARIABLES    ] = ds_map_create();

_list[| __CHATTERBOX.__SECTION2   ] = "-- Children --"
_list[| __CHATTERBOX.TEXTS        ] = ds_list_create();
_list[| __CHATTERBOX.OPTIONS      ] = ds_list_create();
_list[| __CHATTERBOX.TEXTS_META   ] = ds_list_create();
_list[| __CHATTERBOX.OPTIONS_META ] = ds_list_create();

ds_list_mark_as_map( _list, __CHATTERBOX.VARIABLES   );
ds_list_mark_as_list(_list, __CHATTERBOX.TEXTS       );
ds_list_mark_as_list(_list, __CHATTERBOX.OPTIONS     );
ds_list_mark_as_list(_list, __CHATTERBOX.TEXTS_META  );
ds_list_mark_as_list(_list, __CHATTERBOX.OPTIONS_META);



//If a node title has been specified, try to run it
if (_node_title != undefined)
{
    var _key = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
    
    var _instruction = global.__chatterbox_goto[? _key ];
    if (_instruction == undefined)
    {
        show_error("Chatterbox:\nCouldn't find title \"" + string(_node_title) + "\" from Yarn .json file \"" + string(_filename) + "\"\n ", false);
    }
    else
    {
        show_debug_message("Chatterbox: Starting node \"" + _node_title + "\" from \"" + _filename + "\"");
        
        var _variables_map = __CHATTERBOX_VARIABLE_MAP;
        _variables_map[? "visited(" + _key + ")" ] = true;
        if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox:   Set \"visited(" + _key + ")\" to <true>");
        
        chatterbox_step(_list);
    }
}



return _list;