/// @param [left]
/// @param [top]
/// @param [right]
/// @param [bottom]

var _left   = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : CHATTERBOX_DEFAULT_LEFT;
var _top    = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : CHATTERBOX_DEFAULT_TOP;
var _right  = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : CHATTERBOX_DEFAULT_RIGHT;
var _bottom = ((argument_count > 3) && (argument[3] != undefined))? argument[3] : CHATTERBOX_DEFAULT_BOTTOM;



var _list = ds_list_create();

_list[| __CHATTERBOX.__SECTION0  ] = "-- Parameters --";
_list[| __CHATTERBOX.FILENAME    ] = global.__chatterbox_default_file;
_list[| __CHATTERBOX.TITLE       ] = undefined;
_list[| __CHATTERBOX.LEFT        ] = _left;
_list[| __CHATTERBOX.TOP         ] = _top;
_list[| __CHATTERBOX.RIGHT       ] = _right;
_list[| __CHATTERBOX.BOTTOM      ] = _bottom;

_list[| __CHATTERBOX.__SECTION1  ] = "-- State --";
_list[| __CHATTERBOX.INITIALISED ] = false;
_list[| __CHATTERBOX.INSTRUCTION ] = undefined;
_list[| __CHATTERBOX.VARIABLES   ] = ds_map_create();

_list[| __CHATTERBOX.__SECTION2  ] = "-- Children --"
_list[| __CHATTERBOX.TEXTS       ] = ds_list_create();
_list[| __CHATTERBOX.BUTTONS     ] = ds_list_create();

ds_list_mark_as_list(_list, __CHATTERBOX.TEXTS     );
ds_list_mark_as_list(_list, __CHATTERBOX.BUTTONS   );
ds_list_mark_as_map( _list, __CHATTERBOX.VARIABLES );

return _list;