/// @param string

function __chatterbox_parse_json(_string)
{
	var _yarn_json = json_decode(_string);
    
	//Test for JSON made by the standard Yarn editor
	var _node_list = _yarn_json[? "default"];
	if (_node_list != undefined) __chatterbox_trace("    File was made in standard Yarn editor");
    
	//Test for JSON made by Jacquard
	if (_node_list == undefined)
	{
	    var _node_list = _yarn_json[? "nodes"];
	    if (_node_list != undefined) __chatterbox_trace("    File was made by Jacquard");
	}
    
	//Divorce the node list from the JSON
	_yarn_json[? "default" ] = undefined;
	_yarn_json[? "nodes"   ] = undefined;
	ds_map_destroy(_yarn_json);
    
    return _node_list;
}