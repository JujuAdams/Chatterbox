/// @param bodyString

function __chatterbox_body_findreplace(_body)
{
	//Prepare body string for parsing
	_body = string_replace_all(_body, "\n\r", "\n");
	_body = string_replace_all(_body, "\r\n", "\n");
	_body = string_replace_all(_body, "\r"  , "\n");
    
	//Perform find-replace
    var _i = 0;
    repeat(ds_list_size(global.__chatterbox_findreplace_old_string))
    {
	    _body = string_replace_all(_body,
	                                global.__chatterbox_findreplace_old_string[| _i],
	                                global.__chatterbox_findreplace_new_string[| _i]);
        ++_i;
    }
    
    return _body;
}