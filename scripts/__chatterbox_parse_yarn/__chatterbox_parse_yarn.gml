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