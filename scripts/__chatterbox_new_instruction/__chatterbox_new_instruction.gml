/// @param type
/// @param indent
/// @param [content]
/// @param [insertPosition]

function __chatterbox_new_instruction()
{
	var _type     = argument[0];
	var _indent   = argument[1];
	var _content  = (argument_count > 2)? argument[2] : undefined;
	var _position = (argument_count > 3)? argument[3] : undefined;
    
	var _array = array_create(__CHATTERBOX_INSTRUCTION.__SIZE);
	_array[__CHATTERBOX_INSTRUCTION.TYPE     ] = _type;
	_array[__CHATTERBOX_INSTRUCTION.INDENT   ] = _indent;
	_array[__CHATTERBOX_INSTRUCTION.CONTENT  ] = _content;
	_array[__CHATTERBOX_INSTRUCTION.BLOCK_END] = undefined;
    
    
	if (_position != undefined)
	{
	    ds_list_insert(global.__chatterbox_vm, _position, _array);
	}
	else
	{
	    ds_list_insert(global.__chatterbox_vm, global.__chatterbox_insert_pos, _array);
	    global.__chatterbox_insert_pos++;
	}
    
	return _array;
}