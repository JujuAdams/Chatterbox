/// Completes initialisation for Chatterbox
/// This script should be called after chatterbox_init_start() and chatterbox_init_add()
///
/// Once this script has been run, Chatterbox is ready for use!

var _timer = get_timer();

if ( !variable_global_exists("__chatterbox_init_complete" ) )
{
    show_error("Chatterbox:\nchatterbox_init_end() should be called after chatterbox_init_start()\n ", false);
    exit;
}

show_debug_message("Chatterbox: Initialisation started");



var _font_count = ds_map_size(global.__chatterbox_file_data);
var _name = ds_map_find_first(global.__chatterbox_file_data);
repeat(_font_count)
{
    var _font_data = global.__chatterbox_file_data[? _name ];
    show_debug_message("Chatterbox:   Processing file \"" + _name + "\"");
    
    var _filename = _font_data[ __CHATTERBOX_FILE.FILENAME ];
    
    var _buffer = buffer_load(global.__chatterbox_font_directory + _filename);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);
    
    var _chatterbox_map = ds_map_create();
    ds_map_add_map(global.__chatterbox_data, _filename, _chatterbox_map);
    
    var _yarn_json = json_decode(_string);
    var _node_list = _yarn_json[? "default" ];
    var _node_count = ds_list_size(_node_list);
    
    var _title_string = "Chatterbox:     Found " + string(_node_count) + " titles: ";
    var _title_count = 0;
    for(var _i = 0; _i < _node_count; _i++)
    {
        var _node_map   = _node_list[| _i];
        var _node_title = _node_map[? "title" ];
        var _node_body  = _node_map[? "body"  ];
        
        if (__CHATTERBOX_DEBUG) show_debug_message("Chatterbox:     \"" + string(_node_title) + "\" : \"" + string_replace_all(string(_node_body), "\n", "\\n") + "\"");
        _chatterbox_map[? _node_title ] = _node_body;
        
        _title_string += "\"" + _node_title + "\"";
        if (_i < _node_count-1)
        {
            _title_string += ", ";
            _title_count++;
            if (_title_count >= 30)
            {
                show_debug_message(_title_string);
                _title_string = "Chatterbox:     ";
                _title_count = 0;
            }
        }
    }
    show_debug_message(_title_string);
    
    ds_map_destroy(_yarn_json);
}



show_debug_message("Chatterbox: Initialisation complete, took " + string((get_timer() - _timer)/1000) + "ms");
show_debug_message("Chatterbox: Thanks for using Chatterbox!");

global.__chatterbox_init_complete = true;