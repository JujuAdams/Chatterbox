/// @param filename
/// @param buffer

function __chatterbox_class_source(_filename, _buffer) constructor
{
    filename = _filename;
    name     = _filename;
    format   = undefined;
    nodes    = [];
    loaded   = false; //We set this to <true> at the bottom of the constructor
    
    //Read a string from the buffer
    var _old_tell = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, 0);
    var _string = buffer_read(_buffer, buffer_string);
    buffer_seek(_buffer, buffer_seek_start, _old_tell);
    
    //Try to decode the string as a JSON
    var _node_list = undefined;
    var _json = json_decode(_string);
    if (_json >= 0)
    {
        var _node_list = __chatterbox_parse_json(_json);
        if (is_numeric(_node_list)) format = "json";
    }
    
    if (is_undefined(_node_list))
    {
        var _node_list = __chatterbox_parse_yarn(_string);
        format = "yarn";
    }
    
    //If both of these fail, it's some wacky JSON that we don't recognise
    if (_node_list == undefined)
    {
        __chatterbox_error("File format for \"" + filename + "\" is unrecognised.\nThis source file will be ignored");
        return undefined;
    }
    
    __chatterbox_trace("Processing \"", filename, "\" as a source file named \"", name, "\" (format=\"", format, "\")");
    
    //Iterate over all the nodes we found in this source file
    var _n = 0;
    repeat(ds_list_size(_node_list))
    {
        var _node_map = _node_list[| _n];
        var _node = new __chatterbox_class_node(filename, _node_map[? "title"], _node_map[? "body"]);
        __chatterbox_array_add(nodes, _node);
        _n++;
    }
    
    ds_list_destroy(_node_list);
    
    /// @param nodeTitle
    find_node = function(_title)
    {
        var _i = 0;
        repeat(array_length(nodes))
        {
            if (nodes[_i].title == _title) return nodes[_i];
            ++_i;
        }
        
        return undefined;
    }
    
    function toString()
    {
        return "File " + string(filename) + " " + string(nodes);
    }
    
    loaded = true;
}

/// @param string
function __chatterbox_parse_yarn(_string)
{
    var _node_list = ds_list_create();
    
    _string = string_replace_all(_string, "\n\r", "\n");
    _string = string_replace_all(_string, "\r\n", "\n");
    _string = string_replace_all(_string, "\r"  , "\n");
    _string += "\n";
    
    var _body      = "";
    var _title     = "";
    var _in_header = true;
    
    var _pos = string_pos("\n", _string);
    while(_pos > 0)
    {
        var _substring = string_copy(_string, 1, _pos-1);
        _string        = string_delete(_string, 1, _pos);
        _pos           = string_pos("\n", _string);
        
        if (_in_header)
        {
            if (string_copy(_substring, 1, 6) == "title:")
            {
                _title = string_delete(_substring, 1, 6);
                _title = __chatterbox_remove_whitespace(__chatterbox_remove_whitespace(_title, true), false);
            }
            
            if (string_copy(_substring, 1, 3) == "---")
            {
                _in_header = false;
                _body = "";
            }
        }
        else
        {
            if (string_copy(_substring, 1, 3) == "===")
            {
                var _map = ds_map_create();
                _map[? "body" ] = _body;
                _map[? "title"] = _title;
                ds_list_add(_node_list, _map);
                ds_list_mark_as_map(_node_list, ds_list_size(_node_list)-1);
                
                _in_header = true;
                _body      = "";
                _title     = "";
            }
            else
            {
                _body += _substring + "\n";
            }
        }
    }
    
    return _node_list;
}

/// @param JSON
function __chatterbox_parse_json(_json)
{
    //Test for JSON made by the standard Yarn editor
    var _node_list = _json[? "default"];
    if (is_numeric(_node_list) && __CHATTERBOX_DEBUG_LOADER) __chatterbox_trace("File was made in standard Yarn editor");
    
    //Test for JSON made by Jacquard
    if (!is_numeric(_node_list))
    {
        var _node_list = _json[? "nodes"];
        if (is_numeric(_node_list) && __CHATTERBOX_DEBUG_LOADER)
        {
            __chatterbox_trace("File was made by Jacquard");
        }
        else
        {
            _node_list = undefined;
        }
    }
    
    //Divorce the node list from the JSON and clean up our memory
    _json[? "default" ] = undefined;
    _json[? "nodes"   ] = undefined;
    ds_map_destroy(_json);
    
    return _node_list;
}