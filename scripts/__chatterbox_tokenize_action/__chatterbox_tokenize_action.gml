/// @param string
function __chatterbox_tokenize_action(argument0) {

	var _string = argument0;

	var _content = [];
                
	if ((_string == "end if") || (_string == "elseif") || (_string == "else if"))
	{
	    if (CHATTERBOX_ERROR_ON_NONSTANDARD_SYNTAX) __chatterbox_error("<<" + _string + ">> is non-standard Yarn syntax, please use <<endif>>\n \n(Set CHATTERBOX_ERROR_ON_NONSTANDARD_SYNTAX to <false> to hide this error)");
	    _content[0] = _string;
	}
	else
	{
    #region Break down string into tokens
    
	    var _in_string = false;
	    var _in_symbol = false;

	    _string += " ";
	    var _work_length = string_length(_string);
	    var _work_char = "";
	    var _work_char_prev = "";
	    var _work_read_prev = 1;
	    for(var _work_read = 1; _work_read <= _work_length; _work_read++)
	    {
	        var _read = false;
	        var _read_add_char = 0;
	        var _read_parse_operator = false;
                
	        _work_char_prev = _work_char;
	        var _work_char = string_char_at(_string, _work_read);
                
	        if (_in_string)
	        {
	            //Ignore all behaviours until we hit a quote mark
	            if (_work_char == "\"") && (_work_char_prev != "\\")
	            {
	                _read_add_char = 1; //Make sure we get the quote mark in the string
	                _in_string = false;
	                _read = true;
	                //show_debug_message("  found closing quote mark");
	            }
	        }
	        else if (_work_char == "\"") && (_work_char_prev != "\\")
	        {
	            //If we've got an unescaped quote mark, start a string
	            _in_string = true;
	            _read = true;
	            //show_debug_message("  found open quote mark");
	        }
	        else if (_work_char == "!")
	                || (_work_char == "=")
	                || (_work_char == "<")
	                || (_work_char == ">")
	                || (_work_char == "+")
	                || (_work_char == "-")
	                || (_work_char == "*")
	                || (_work_char == "/")
	                || (_work_char == "&")
	                || (_work_char == "|")
	                || (_work_char == "^")
	                || (_work_char == "`")
	        {
	            if (!_in_symbol)
	            {
	                //If we've found an operator symbol then do a standard read and begin reading a symbol
	                _in_symbol = true;
	                _read = true;
	                //show_debug_message("  found symbol start");
	            }
	        }
	        else if (_in_symbol)
	        {
	            //If we're reading a symbol but this character *isn't* a symbol character, do a read
	            _in_symbol = false;
	            _read = true;
	            _read_parse_operator = true;
	            //show_debug_message("  found symbol end");
	        }
	        else if (_work_char == " ")
	                || (_work_char == ",")
	        {
	            //Always read at spaces and commas
	            _read = true;
	            //show_debug_message("  found space or comma");
	        }
	        else if (_work_char == "(") || (_work_char == ")")
	        {
	            //Always read at brackets
	            _read = true;
	            //show_debug_message("  found bracket");
	        }
	        else if (_work_char_prev == "(") || (_work_char_prev == ")")
	        {
	            //Always read at brackets
	            _read = true;
	            //show_debug_message("  found bracket pt.2");
	        }
                
	        if (_read)
	        {
	            var _out_string = string_copy(_string, _work_read_prev, _work_read + _read_add_char - _work_read_prev);
	            //show_debug_message("    copied \"" + _out_string + "\"");
	            _out_string = __chatterbox_remove_whitespace(_out_string, true);
	            _out_string = __chatterbox_remove_whitespace(_out_string, false);
	            _out_string = string_replace_all(_out_string, "\\\"", "\""); //Replace \" with "
                    
	            switch(_out_string)
	            {
	                case "and": _out_string = "&&"; break;
	                case "&"  : _out_string = "&&"; break;
	                case "le" : _out_string = "<";  break;
	                case "gt" : _out_string = ">";  break;
	                case "or" : _out_string = "||"; break;
	                case "`"  : _out_string = "||"; break;
	                case "|"  : _out_string = "||"; break;
	                case "leq": _out_string = "<="; break;
	                case "geq": _out_string = ">="; break;
	                case "eq" : _out_string = "=="; break;
	                case "is" : _out_string = "=="; break;
	                case "neq": _out_string = "!="; break;
	                case "to" : _out_string = "=";  break;
	                case "not": _out_string = "!";  break;
	            }
                    
	            if (_out_string != "")
	            {
	                _content[array_length_1d(_content)] = _out_string;
	                if (array_length_1d(_content) == 1)
	                {
	                    _content[1] = undefined; //Reserve a slot for the top-level node in the evaluation tree
	                    _content[2] = "()";      //Reserve a slot for the generic function token
	                }
	            }
                    
	            _work_read_prev = _work_read + _read_add_char;
	        }
	    }
    
    #endregion
    
    #region BUild evaluation tree
    
	    var _content_length = array_length_1d(_content);
	    var _eval_tree_root = array_create(_content_length-3);
	    for(var _i = 3; _i < _content_length; _i++) _eval_tree_root[_i-3] = _i;
	    _content[1] = _eval_tree_root;
	    _content[2] = "()";
    
	    var _queue = ds_list_create();
	    ds_list_add(_queue, 1);
                
	    repeat(9999)
	    {
	        if (ds_list_empty(_queue)) break;
                    
	        var _element_index = _queue[| 0];
	        ds_list_delete(_queue, 0);
                    
	        var _element = _content[_element_index];
	        if (!is_array(_element)) continue;
	        var _element_length = array_length_1d(_element);
                    
	        var _break = false;
	        for(var _op = 0; _op < global.__chatterbox_op_count; _op++)
	        {
	            var _operator = global.__chatterbox_op_list[| _op];
                        
	            for(var _e = _element_length-1; _e > 0; _e--) //Go backwards. This solves issues with nested brackets
	            {
	                var _value = _content[_element[_e]];
                            
	                if (_value == _operator)
	                {
	                    if (_operator == "(")
	                    {
                        #region Split up bracketed expressions
                                    
	                        //Find the first close bracket token
	                        for(var _f = _e+1; _f < _element_length; _f++) if (_content[_element[_f]] == ")") break;
                                    
	                        if (_f < _element_length)
	                        {
	                            var _function = undefined;
	                            if (_e > 0)
	                            {
	                                _function = _content[_element[_e-1]];
	                                if (!is_string(_function) || (_function == "()") || (ds_list_find_index(global.__chatterbox_op_list, _function) >= 0)) _function = undefined;
	                            }
                                        
	                            if (_function == undefined)
	                            {
	                                //Standard "structural" bracket
                                            
	                                var _new_element = [];
	                                array_copy(_new_element, 0,   _element, _e+1, _f-_e-1);
                                            
	                                _content[array_length_1d(_content)] = _new_element; //Add the new sub-array to the overall content array
	                                ds_list_add(_queue, array_length_1d(_content)-1);   //Add the index of the new sub-array to the processing queue
                                            
	                                _replacement_element = array_create(_element_length + _e - _f); //Create a new element array
	                                array_copy(_replacement_element, 0,   _element, 0, _e);
	                                _replacement_element[_e] = array_length_1d(_content)-1; //Set the index of the new sub-array in the replacement element array
	                                array_copy(_replacement_element, _e+1,   _element, _f+1, _element_length-_f);
                                            
	                                _content[_element_index] = _replacement_element;
	                                ds_list_add(_queue, _element_index); //Add the index of the replacement array to the processing queue
	                            }
	                            else
	                            {
	                                //Function call
                                            
	                                var _new_element = [_element[_e-1], 2];
	                                array_copy(_new_element, 2,   _element, _e+1, _f-_e-1);
                                            
	                                _content[array_length_1d(_content)] = _new_element; //Add the new sub-array to the overall content array
	                                ds_list_add(_queue, array_length_1d(_content)-1);   //Add the index of the new sub-array to the processing queue
                                            
	                                _replacement_element = array_create(_element_length - 1 + _e - _f); //Create a new element array
	                                array_copy(_replacement_element, 0,   _element, 0, _e-1);
	                                _replacement_element[_e-1] = array_length_1d(_content)-1; //Set the index of the new sub-array in the replacement element array
	                                array_copy(_replacement_element, _e+1,   _element, _f+1, _element_length-_f);
                                            
	                                _content[_element_index] = _replacement_element;
	                                ds_list_add(_queue, _element_index); //Add the index of the replacement array to the processing queue
	                            }
	                        }
	                        else
	                        {
	                            //Error!
	                            __chatterbox_error("Syntax error");
	                            _content[_element_index] = undefined;
	                        }
                                    
                        #endregion
	                    }
	                    else if (_operator == "!") || ((_operator == "-") && (_op == global.__chatterbox_negative_op_index))
	                    {
                        #region Unary operators
                                    
	                        if (_e < _element_length-1) //For a unary operator, we cannot be the last element
	                        {
	                            var _new_element = [];
	                            array_copy(_new_element, 0,   _element, _e, 2);
                                        
	                            _content[array_length_1d(_content)] = _new_element; //Add the new sub-array to the overall content array
	                            ds_list_add(_queue, array_length_1d(_content)-1);   //Add the index of the new sub-array to the processing queue
                                        
	                            _replacement_element = array_create(_element_length-1); //Create a new element array
	                            array_copy(_replacement_element, 0,   _element, 0, _e);
	                            _replacement_element[_e] = array_length_1d(_content)-1; //Set the index of the new sub-array in the replacement element array
	                            array_copy(_replacement_element, _e+1,   _element, _e+2, _element_length-(_e+2));
                                        
	                            _content[_element_index] = _replacement_element;
	                            ds_list_add(_queue, _element_index); //Add the index of the replacement array to the processing queue
	                        }
	                        else
	                        {
	                            //Error!
	                            __chatterbox_error("Syntax error");
	                            _content[_element_index] = undefined;
	                        }
                                    
                        #endregion
	                    }
	                    else
	                    {
                        #region Binary operators
                                    
	                        if (_element_length < 3) //For a binary operator, we need at least three tokens in the array
	                        {
	                            if !((_operator == "-") && (_op == 8) && (_e == 0)) //Don't report this error if the subtraction sign might be a negative sign
	                            {
	                                //Error!
	                                __chatterbox_error("Syntax error");
	                                _content[_element_index] = undefined;
	                            }
	                        }
	                        else if (_e <= 0) || (_e >= _element_length-1) //A binary operator must be in-between two tokens
	                        {
	                            if !((_operator == "-") && (_op == 8) && (_e == 0)) //Don't report this error if the subtraction sign might be a negative sign
	                            {
	                                //Error!
	                                __chatterbox_error("Syntax error");
	                                _content[_element_index] = undefined;
	                            }
	                        }
	                        else if (_element_length > 3)
	                        {
	                            var _replacement_element = [_element[0],
	                                                        _element[_e],
	                                                        _element[_element_length-1]];
                                        
	                            //Split up the left-hand side of the array
	                            if (_e > 1)
	                            {
	                                var _new_element = [];
	                                array_copy(_new_element, 0,   _element, 0, _e);
                                            
	                                _content[array_length_1d(_content)] = _new_element;    //Add the new sub-array to the overall content array
	                                ds_list_add(_queue, array_length_1d(_content)-1);      //Add the index of the new sub-array to the processing queue
	                                _replacement_element[0] = array_length_1d(_content)-1; //Set the index of the new sub-array in the replacement element array
	                            }
                                        
	                            //Split up the right-hand side of the array
	                            if (_e < _element_length-2)
	                            {
	                                var _new_element = [];
	                                array_copy(_new_element, 0,   _element, _e+1, _element_length-_e-1);
                                            
	                                _content[array_length_1d(_content)] = _new_element;    //Add the new sub-array to the overall content array
	                                ds_list_add(_queue, array_length_1d(_content)-1);      //Add the index of the new sub-array to the processing queue
	                                _replacement_element[2] = array_length_1d(_content)-1; //Set the index of the new sub-array in the replacement element array
	                            }
                                        
	                            _content[_element_index] = _replacement_element;
	                        }
	                        else
	                        {
	                            //No action needed
	                        }
                                    
                        #endregion
	                    }
                                
	                    _break = true;
	                    break;
	                }
	            }
                        
	            if (_break) break;
	        }
	    }
                
	    ds_list_destroy(_queue);
    
    #endregion
	}

	return _content;


}
