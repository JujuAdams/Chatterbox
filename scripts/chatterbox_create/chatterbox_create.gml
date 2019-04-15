var _list = ds_list_create();

_list[| __CHATTERBOX.__SECTION0   ] = "-- Parameters --";
_list[| __CHATTERBOX.FILENAME     ] = global.__chatterbox_default_file;
_list[| __CHATTERBOX.TITLE        ] = undefined;

_list[| __CHATTERBOX.__SECTION1   ] = "-- State --";
_list[| __CHATTERBOX.INITIALISED  ] = false;
_list[| __CHATTERBOX.INSTRUCTION  ] = undefined;
_list[| __CHATTERBOX.VARIABLES    ] = ds_map_create();
_list[| __CHATTERBOX.EXECUTED_MAP ] = ds_map_create();

_list[| __CHATTERBOX.__SECTION2   ] = "-- Children --"
_list[| __CHATTERBOX.TEXTS        ] = ds_list_create();
_list[| __CHATTERBOX.BUTTONS      ] = ds_list_create();
_list[| __CHATTERBOX.TEXTS_META   ] = ds_list_create();
_list[| __CHATTERBOX.BUTTONS_META ] = ds_list_create();

ds_list_mark_as_map( _list, __CHATTERBOX.VARIABLES   );
ds_list_mark_as_map( _list, __CHATTERBOX.EXECUTED_MAP);
ds_list_mark_as_list(_list, __CHATTERBOX.TEXTS       );
ds_list_mark_as_list(_list, __CHATTERBOX.BUTTONS     );
ds_list_mark_as_list(_list, __CHATTERBOX.TEXTS_META  );
ds_list_mark_as_list(_list, __CHATTERBOX.BUTTONS_META);

return _list;