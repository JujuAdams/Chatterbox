/// @param filename
/// @param string

function __chatterbox_class_source(_filename, _string) constructor
{
    filename = _filename;
    name     = _filename;
    tags     = {};
    nodes    = [];
    loaded   = false; //We set this to <true> at the bottom of the constructor
    
    __chatterbox_trace("Parsing \"", filename, "\" as a source file named \"", name, "\"");
    
    try
    {
        var _file_struct = __chatterbox_parse_yarn(_string);
    }
    catch(_error)
    {
        show_debug_message(_error);
        __chatterbox_error("\"" + filename + "\" could not be parsed. This source file will be ignored");
        exit;
    }
    
    tags = _file_struct.tags;
    var _nodes_temp_array = _file_struct.nodes;
    
    //Iterate over all the nodes we found in this source file
    var _n = 0;
    repeat(array_length(_nodes_temp_array))
    {
        var _node_temp_struct = _nodes_temp_array[_n];
        
        var _node_tags = _node_temp_struct.tags;
        if (!variable_struct_exists(_node_tags, "title"))
        {
            __chatterbox_error("Node in \"", filename, "\" has no title tag");
        }
        else
        {
            var _node = new __chatterbox_class_node(filename, _node_tags.title, _node_temp_struct.body);
            __chatterbox_array_add(nodes, _node);
        }
        
        _n++;
    }
    
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
    var _body_start       = undefined;
    var _start_of_line    = true;
    var _seen_first_node  = false;
    var _in_body          = false;
    var _line_is_file_tag = false;
    var _line_is_node_tag = false;
    
    var _node_tags = {};
    
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
                buffer_poke(_buffer, buffer_tell(_buffer) - 1, buffer_u8, _byte);
                
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
                            _body_start = buffer_tell(_buffer);
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
                            var _old_tell = buffer_tell(_buffer);
                            buffer_poke(_buffer, _string_start, buffer_u8, 0x00);
                            buffer_seek(_buffer, buffer_seek_start, _body_start);
                            var _string = buffer_read(_buffer, buffer_string);
                            buffer_poke(_buffer, _string_start, buffer_u8, _byte);
                            buffer_seek(_buffer, buffer_seek_start, _old_tell);
                            
                            var _node_struct = { tags : _node_tags, body : _string };
                            array_push(_node_array, _node_struct);
                            
                            _in_body = false;
                            _node_tags = {};
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
    
    if (_in_body)
    {
        throw "File ended without a final body terminator (===)";
    }
    
    if (variable_struct_names_count(_node_tags) > 0)
    {
        throw "File ended in the middle of a node header";
    }
    
    return _file_struct;
}