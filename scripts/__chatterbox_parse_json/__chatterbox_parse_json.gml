/// @param JSON

function __chatterbox_parse_json(_json)
{
	//Test for JSON made by the standard Yarn editor
	var _node_list = _json[? "default"];
	if (_node_list != undefined) __chatterbox_trace("File was made in standard Yarn editor");
    
	//Test for JSON made by Jacquard
	if (_node_list == undefined)
	{
	    var _node_list = _json[? "nodes"];
	    if (_node_list != undefined) __chatterbox_trace("File was made by Jacquard");
	}
    
	//Divorce the node list from the JSON and clean up our memory
	_json[? "default" ] = undefined;
	_json[? "nodes"   ] = undefined;
	ds_map_destroy(_json);
    
    return _node_list;
}