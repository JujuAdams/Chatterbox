/// @param [left]
/// @param [top]
/// @param [right]
/// @param [bottom]

var _left   = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : CHATTERBOX_DEFAULT_LEFT;
var _top    = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : CHATTERBOX_DEFAULT_TOP;
var _right  = ((argument_count > 2) && (argument[2] != undefined))? argument[2] : CHATTERBOX_DEFAULT_RIGHT;
var _bottom = ((argument_count > 3) && (argument[3] != undefined))? argument[3] : CHATTERBOX_DEFAULT_BOTTOM;

var _array = array_create(__CHATTERBOX_HOST.__SIZE);

_array[ __CHATTERBOX_HOST.__SECTION0       ] = "-- Parameters --";
_array[ __CHATTERBOX_HOST.FILENAME         ] = global.__chatterbox_open_file;
_array[ __CHATTERBOX_HOST.TITLE            ] = undefined;
_array[ __CHATTERBOX_HOST.LEFT             ] = _left;
_array[ __CHATTERBOX_HOST.TOP              ] = _top;
_array[ __CHATTERBOX_HOST.RIGHT            ] = _right;
_array[ __CHATTERBOX_HOST.BOTTOM           ] = _bottom;

_array[ __CHATTERBOX_HOST.__SECTION1       ] = "-- State --";
_array[ __CHATTERBOX_HOST.BODY             ] = undefined;
_array[ __CHATTERBOX_HOST.LINE             ] = undefined;

_array[ __CHATTERBOX_HOST.__SECTION2       ] = "-- Children --"
_array[ __CHATTERBOX_HOST.PRIMARY_SCRIBBLE ] = undefined;
_array[ __CHATTERBOX_HOST.SCRIBBLES        ] = [];
_array[ __CHATTERBOX_HOST.BUTTONS          ] = [];
_array[ __CHATTERBOX_HOST.INSTANCES        ] = [];

return _array;