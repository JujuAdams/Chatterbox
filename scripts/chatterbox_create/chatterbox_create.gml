/// @param [left]
/// @param [top]
/// @param [right]
/// @param [bottom]

var _left   = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : CHATTERBOX_DEFAULT_LEFT;
var _top    = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : CHATTERBOX_DEFAULT_TOP;
var _right  = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : CHATTERBOX_DEFAULT_RIGHT;
var _bottom = ((argument_count > 3) && (argument[3] != undefined))? argument[3] : CHATTERBOX_DEFAULT_BOTTOM;



var _list = ds_list_create();

_list[| __CHATTERBOX_HOST.__SECTION0 ] = "-- Parameters --";
_list[| __CHATTERBOX_HOST.FILENAME   ] = global.__chatterbox_default_file;
_list[| __CHATTERBOX_HOST.TITLE      ] = undefined;
_list[| __CHATTERBOX_HOST.LEFT       ] = _left;
_list[| __CHATTERBOX_HOST.TOP        ] = _top;
_list[| __CHATTERBOX_HOST.RIGHT      ] = _right;
_list[| __CHATTERBOX_HOST.BOTTOM     ] = _bottom;

_list[| __CHATTERBOX_HOST.__SECTION1 ] = "-- State --";
_list[| __CHATTERBOX_HOST.LINE       ] = undefined;
_list[| __CHATTERBOX_HOST.INDENT     ] = undefined;

_list[| __CHATTERBOX_HOST.__SECTION2 ] = "-- Children --"
_list[| __CHATTERBOX_HOST.SCRIBBLES  ] = ds_list_create();
_list[| __CHATTERBOX_HOST.BUTTONS    ] = ds_list_create();
_list[| __CHATTERBOX_HOST.INSTANCES  ] = ds_list_create();

ds_list_mark_as_list(_list, __CHATTERBOX_HOST.SCRIBBLES);
ds_list_mark_as_list(_list, __CHATTERBOX_HOST.BUTTONS  );
ds_list_mark_as_list(_list, __CHATTERBOX_HOST.INSTANCES);

return _list;