/// @param filename
/// @param string

function __ChatterboxClassSource(_filename, _string) constructor
{
    filename = _filename;
    name     = _filename;
    tags     = [];
    nodes    = [];
    loaded   = false; //We set this to <true> at the bottom of the constructor
    
    __ChatterboxTrace("Parsing \"", filename, "\" as a source file named \"", name, "\"");
    
    try
    {
        var _file_struct = __ChatterboxParseYarn(_string);
    }
    catch(_error)
    {
        show_debug_message(_error);
        __ChatterboxError("\"" + filename + "\" could not be parsed. This source file will be ignored");
        exit;
    }
    
    tags = _file_struct.tags;
    var _nodes_temp_array = _file_struct.nodes;
    
    //Iterate over all the nodes we found in this source file
    var _n = 0;
    repeat(array_length(_nodes_temp_array))
    {
        var _node_temp_struct = _nodes_temp_array[_n];
        
        var _node_metadata = _node_temp_struct.metadata;
        if (!variable_struct_exists(_node_metadata, "title"))
        {
            __ChatterboxError("Node in \"", filename, "\" has no title metadata");
        }
        else
        {
            var _node = new __ChatterboxClassNode(filename, _node_metadata, _node_temp_struct.body);
            array_push(nodes, _node);
        }
        
        _n++;
    }
    
    
    
    /// @param nodeTitle
    static FindNode = function(_title)
    {
        var _i = 0;
        repeat(array_length(nodes))
        {
            if (nodes[_i].title == _title) return nodes[_i];
            ++_i;
        }
        
        return undefined;
    }
    
    static NodeExists = function(_nodeTitle)
    {
        return (FindNode(_nodeTitle) != undefined);
    }
    
    static NodeCount = function()
    {
        return array_length(global.chatterboxFiles[? _sourceName].nodes);
    }
    
    static GetTags = function()
    {
        return tags;
    }
    
    static toString = function()
    {
        return "File " + string(filename) + " " + string(nodes);
    }
    
    
    
    loaded = true;
}

/// @param string
function __ChatterboxParseYarn(_input_string)
{
    var _node_array  = [];
    var _file_tags   = [];
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
    var _in_comment       = false;
    
    var _node_metadata = {};
    
    repeat(buffer_get_size(_buffer) - buffer_tell(_buffer))
    {
        var _byte = buffer_read(_buffer, buffer_u8);
        
        var _entered_comment = (!_in_comment && (_byte == 47) && (buffer_peek(_buffer, buffer_tell(_buffer), buffer_u8) == 47));
        
        if ((_byte == 0) || (_byte == 10) || (_byte == 13) || _entered_comment)
        {
            if (!_in_comment && (buffer_tell(_buffer) > _string_start + 1))
            {
                buffer_poke(_buffer, buffer_tell(_buffer) - 1, buffer_u8, 0x00);
                buffer_seek(_buffer, buffer_seek_start, _string_start);
                var _string = buffer_read(_buffer, buffer_string);
                buffer_poke(_buffer, buffer_tell(_buffer) - 1, buffer_u8, _byte);
                
                var _string_trimmed = __ChatterboxRemoveWhitespace(_string, all);
                
                if (_line_is_file_tag)
                {
                    if (__CHATTERBOX_DEBUG_LOADER) __ChatterboxTrace("Found file tag \"", _string_trimmed, "\"");
                    if (CHATTERBOX_ESCAPE_FILE_TAGS) _string_trimmed = __ChatterboxUnescapeString(_string_trimmed);
                    array_push(_file_tags, _string_trimmed);
                }
                else
                {
                    _seen_first_node = true;
                    
                    if (_string_trimmed == "---") //Separator between node header and node body
                    {
                        if (_in_body)
                        {
                            __ChatterboxTrace("Warning! \"---\" found outside of node header definition");
                        }
                        else
                        {
                            _in_body = true;
                            _body_start = buffer_tell(_buffer);
                        }
                    }
                    else if (_string_trimmed == "===") //Node terminator
                    {
                        if (!_in_body)
                        {
                            __ChatterboxTrace("Warning! \"===\" found outside of node body definition");
                        }
                        else
                        {
                            var _old_tell = buffer_tell(_buffer);
                            buffer_poke(_buffer, _string_start, buffer_u8, 0x00);
                            buffer_seek(_buffer, buffer_seek_start, _body_start);
                            var _string = buffer_read(_buffer, buffer_string);
                            buffer_poke(_buffer, _string_start, buffer_u8, _byte);
                            buffer_seek(_buffer, buffer_seek_start, _old_tell);
                            
                            if (__CHATTERBOX_DEBUG_LOADER) __ChatterboxTrace("Creating node \"", __ChatterboxStringLimit(_string, 100), "\"    ", _node_metadata);
                            
                            var _node_struct = { metadata : _node_metadata, body : _string };
                            array_push(_node_array, _node_struct);
                            
                            _in_body = false;
                            _node_metadata = {};
                        }
                    }
                    else if (!_in_body) //Treat everything in the header as key:value pairs
                    {
                        var _colon_pos = string_pos(":", _string_trimmed);
                        
                        if (_colon_pos == 0)
                        {
                            __ChatterboxTrace("Warning! String found in a node header tag was not a key:value pair (", _string, ")");
                        }
                        else
                        {
                            var _key   = string_copy(_string_trimmed, 1, _colon_pos - 1);
                            var _value = string_copy(_string_trimmed, _colon_pos + 1, string_length(_string_trimmed) - _colon_pos);
                            _key   = __ChatterboxRemoveWhitespace(_key,   all);
                            _value = __ChatterboxRemoveWhitespace(_value, all);
                            
                            if (CHATTERBOX_ESCAPE_NODE_TAGS)
                            {
                                _key   = __ChatterboxUnescapeString(_key  );
                                _value = __ChatterboxUnescapeString(_value);
                            }
                            
                            if (__CHATTERBOX_DEBUG_LOADER) __ChatterboxTrace("Found node metadata \"", _key, "\" = \"", _value, "\"");
                            if (variable_struct_exists(_node_metadata, _key)) __ChatterboxTrace("Warning! Duplicate node metadata found \"", _key, "\"");
                            _node_metadata[$ _key] = _value;
                        }
                    }
                }
            }
            
            _in_comment = _entered_comment;
            _entered_comment = false;
            
            _string_start     = buffer_tell(_buffer);
            _start_of_line    = true;
            _line_is_file_tag = false;
        }
        else if (!_in_comment)
        {
            if (_start_of_line && !_seen_first_node)
            {
                if (_byte == ord("#"))
                {
                    _line_is_file_tag = true;
                    _string_start = buffer_tell(_buffer);
                    _start_of_line = false;
                }
                else if (_byte > ord(" ")) //Not whitespace
                {
                    _start_of_line = false;
                }
            }
        }
        
        if (_byte == 0x00) break;
    }
    
    if (_in_body)
    {
        __ChatterboxTrace("Warning! File ended without a final body terminator (===)");
        
        var _old_tell = buffer_tell(_buffer);
        buffer_poke(_buffer, _string_start, buffer_u8, 0x00);
        buffer_seek(_buffer, buffer_seek_start, _body_start);
        var _string = buffer_read(_buffer, buffer_string);
        buffer_poke(_buffer, _string_start, buffer_u8, _byte);
        buffer_seek(_buffer, buffer_seek_start, _old_tell);
        
        if (__CHATTERBOX_DEBUG_LOADER) __ChatterboxTrace("Creating node \"", __ChatterboxStringLimit(_string, 100), "\"    ", _node_metadata);
        
        var _node_struct = { metadata : _node_metadata, body : _string };
        array_push(_node_array, _node_struct);
        
        _node_metadata = {};
    }
    
    buffer_delete(_buffer);
    
    if (variable_struct_names_count(_node_metadata) > 0)
    {
        throw "File ended in the middle of a node header";
    }
    
    return _file_struct;
}