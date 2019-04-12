/// @param chatterbox
/// @param nodeTitle
/// @param [filename]

var _chatterbox = argument[0];
var _node_title = argument[1];

if (argument_count > 2)
{
    var _filename = argument[2];
    
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
    
    _chatterbox[| __CHATTERBOX_HOST.FILENAME ] = _filename;
}
else
{
    _filename = _chatterbox[| __CHATTERBOX_HOST.FILENAME ];
}

var _title_map = global.__chatterbox_data[? _filename ];
if (_title_map == undefined)
{
    show_error("Chatterbox:\nCouldn't find Yarn .json file \"" + string(_filename) + "\"\n ", false);
    return false;
}

var _instruction_list = _title_map[? _node_title ];
if (_instruction_list == undefined)
{
    show_error("Chatterbox:\nCouldn't find title \"" + string(_node_title) + "\" in Yarn .json file \"" + string(_filename) + "\"\n ", false);
    return false;
}

if (!ds_exists(_instruction_list, ds_type_list))
{
    show_error("Chatterbox:\nds_list not found for title \"" + string(_node_title) + "\" in Yarn .json file \"" + string(_filename) + "\"\nThis is a weird error and should never happen!\n ", false);
    return false;
}

_chatterbox[| __CHATTERBOX_HOST.TITLE    ] = _node_title;
_chatterbox[| __CHATTERBOX_HOST.FILENAME ] = _filename;

if (ds_list_size(_instruction_list) == 0)
{
    return false;
}

var _instruction_array = _instruction_list[| 0];
var _indent  = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT  ];
var _type    = _instruction_array[ __CHATTERBOX_INSTRUCTION.TYPE    ];
var _content = _instruction_array[ __CHATTERBOX_INSTRUCTION.CONTENT ];

_chatterbox[| __CHATTERBOX_HOST.LINE   ] = 0;
_chatterbox[| __CHATTERBOX_HOST.INDENT ] = _indent;

if (_type == __CHATTERBOX_VM_TEXT)
{
    ds_list_insert(_chatterbox[| __CHATTERBOX_HOST.SCRIBBLES ], 0, scribble_create(_content));
}