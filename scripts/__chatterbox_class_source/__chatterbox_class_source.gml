/// @param filename
/// @param string

function __chatterbox_class_source(_filename, _string) constructor
{
    filename = _filename;
    name     = _filename;
    format   = undefined;
    nodes    = [];
    loaded   = false; //We set this to <true> at the bottom of the constructor
    
    if (os_browser != browser_not_a_browser)
    {
        __chatterbox_trace("Replacing tabs with spaces to work around GM's janky as f*** JSON parser");
        _string = string_replace_all(_string, "\t", "    ");
    }
    
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
    static find_node = function(_title)
    {
        var _i = 0;
        repeat(array_length(nodes))
        {
            if (nodes[_i].title == _title) return nodes[_i];
            ++_i;
        }
        
        return undefined;
    }
    
    static toString = function()
    {
        return "File " + string(filename) + " " + string(nodes);
    }
    
    loaded = true;
}

/// @param string
function __chatterbox_parse_yarn(_input_string)
{
    var _node_array  = [];
    var _file_tags   = {};
    var _file_struct = { tags : _file_tags, nodes : _node_array };
    
    var _buffer = buffer_create(string_byte_length(_input_string)+1, buffer_fixed, 1);
    buffer_write(_buffer, buffer_string, _input_string);
    buffer_seek(_buffer, buffer_seek_start, 0);
    
    if (buffer_get_size(_buffer) >= 4)
    {
        //Ignore the BOM, if one exists
        var _first_u32 = buffer_peek(_buffer, 0, buffer_u32);
        if ((_first_u32 & 0x0000FFFF) == 0x0000FEFF) buffer_seek(_buffer, buffer_seek_start, 2);
        if ((_first_u32 & 0x0000FFFF) == 0x0000FFFE) buffer_seek(_buffer, buffer_seek_start, 2);
        if ((_first_u32 & 0x00FFFFFF) == 0x00BFBBEF) buffer_seek(_buffer, buffer_seek_start, 3);
    }
    
    var _string_start     = buffer_tell(_buffer);
    var _start_of_line    = true;
    var _seen_first_node  = false;
    var _in_body          = false;
    var _line_is_file_tag = false;
    var _line_is_node_tag = false;
    
    var _line_array  = [];
    var _node_tags   = {};
    var _node_struct = { tags : _node_tags, lines : _line_array };
    array_push(_node_array, _node_struct);
    
    repeat(buffer_get_size(_buffer) - buffer_tell(_buffer))
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        if (_byte == 0x00) break;
        
        if ((_byte == 10) || (_byte == 13))
        {
            if (buffer_tell(_buffer) > _string_start + 1)
            {
                buffer_poke(_buffer, buffer_tell(_buffer) - 1, buffer_u8, 0x00);
                buffer_seek(_buffer, buffer_seek_start, _string_start);
                
                var _string = buffer_read(_buffer, buffer_string);
                var _string_trimmed = __chatterbox_remove_whitespace(_string, all);
                
                show_debug_message(_string);
                
                if (_line_is_file_tag || _line_is_node_tag)
                {
                    var _colon_pos = string_pos(":", _string_trimmed);
                    
                    if (_colon_pos == 0)
                    {
                        __chatterbox_trace("Warning! String found in a file tag was not a key:value pair (", _string, ")");
                    }
                    else
                    {
                        var _key   = string_copy(_string_trimmed, 1, _colon_pos - 1);
                        var _value = string_copy(_string_trimmed, _colon_pos + 1, string_length(_string_trimmed) - _colon_pos);
                        _key   = __chatterbox_remove_whitespace(_key,   all);
                        _value = __chatterbox_remove_whitespace(_value, all);
                        
                        _file_tags[$ _key] = _value;
                    }
                }
                else
                {
                    
                    _seen_first_node = true;
                    
                    if (_string_trimmed == "---") //Separator between node header and node body
                    {
                        if (_in_body)
                        {
                            __chatterbox_trace("Warning! \"---\" found outside of node header definition");
                        }
                        else
                        {
                            _in_body = true;
                        }
                    }
                    else if (_string_trimmed == "===") //Nodew terminator
                    {
                        if (!_in_body)
                        {
                            __chatterbox_trace("Warning! \"===\" found outside of node body definition");
                        }
                        else
                        {
                            _in_body = false;
                            
                            _line_array  = [];
                            _node_tags   = {};
                            _node_struct = { tags : _node_tags, lines : _line_array };
                            array_push(_node_array, _node_struct);
                        }
                    }
                    else if (!_in_body) //Treat everything in the header as key:value pairs
                    {
                        var _colon_pos = string_pos(":", _string_trimmed);
                        
                        if (_colon_pos == 0)
                        {
                            __chatterbox_trace("Warning! String found in a node header tag was not a key:value pair (", _string, ")");
                        }
                        else
                        {
                            var _key   = string_copy(_string_trimmed, 1, _colon_pos - 1);
                            var _value = string_copy(_string_trimmed, _colon_pos + 1, string_length(_string_trimmed) - _colon_pos);
                            _key   = __chatterbox_remove_whitespace(_key,   all);
                            _value = __chatterbox_remove_whitespace(_value, all);
                            
                            _node_tags[$ _key] = _value;
                        }
                    }
                    else
                    {
                        array_push(_line_array, _string);
                    }
                }
            }
            
            _string_start     = buffer_tell(_buffer);
            _start_of_line    = true;
            _line_is_file_tag = false;
            _line_is_node_tag = false;
        }
        else if (_start_of_line && !_seen_first_node)
        {
            if (_byte == 35)
            {
                _line_is_file_tag = true;
                _string_start = buffer_tell(_buffer);
                _start_of_line = false;
            }
            else if (_byte > 32)
            {
                _start_of_line = false;
            }
        }
    }
    
    
    
    
    
    buffer_delete(_buffer);
    
    
    
    ////Remove the byte order mark at the start of the string (if we find it)
    //if (ord(string_char_at(_string, 1)) == 65279) _string = string_delete(_string, 1, 1);
    //
    //_string = string_replace_all(_string, "\n\r", "\n");
    //_string = string_replace_all(_string, "\r\n", "\n");
    //_string = string_replace_all(_string, "\r"  , "\n");
    //_string += "\n";
    //
    //var _body      = "";
    //var _title     = "";
    //var _in_header = true;
    //
    //var _pos = string_pos("\n", _string);
    //while(_pos > 0)
    //{
    //    var _substring = string_copy(_string, 1, _pos-1);
    //    _string        = string_delete(_string, 1, _pos);
    //    _pos           = string_pos("\n", _string);
    //    
    //    if (_in_header)
    //    {
    //        if (string_copy(_substring, 1, 6) == "title:")
    //        {
    //            _title = string_delete(_substring, 1, 6);
    //            _title = __chatterbox_remove_whitespace(__chatterbox_remove_whitespace(_title, true), false);
    //        }
    //        
    //        if (string_copy(_substring, 1, 3) == "---")
    //        {
    //            _in_header = false;
    //            _body = "";
    //        }
    //    }
    //    else
    //    {
    //        if (string_copy(_substring, 1, 3) == "===")
    //        {
    //            var _map = ds_map_create();
    //            _map[? "body" ] = _body;
    //            _map[? "title"] = _title;
    //            ds_list_add(_node_list, _map);
    //            ds_list_mark_as_map(_node_list, ds_list_size(_node_list)-1);
    //            
    //            _in_header = true;
    //            _body      = "";
    //            _title     = "";
    //        }
    //        else
    //        {
    //            _body += _substring + "\n";
    //        }
    //    }
    //}
    
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
            __chatterbox_trace("Node list not found");
            _node_list = undefined;
        }
    }
    
    //Divorce the node list from the JSON and clean up our memory
    _json[? "default" ] = undefined;
    _json[? "nodes"   ] = undefined;
    ds_map_destroy(_json);
    
    return _node_list;
}