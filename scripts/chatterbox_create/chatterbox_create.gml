/// @param originX
/// @param originY

var _origin_x = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : 0;
var _origin_y = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : 0;

var _list = ds_list_create();

_list[| __CHATTERBOX.__SECTION0   ] = "-- Parameters --";
_list[| __CHATTERBOX.FILENAME     ] = global.__chatterbox_default_file;
_list[| __CHATTERBOX.TITLE        ] = undefined;
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

return _list;