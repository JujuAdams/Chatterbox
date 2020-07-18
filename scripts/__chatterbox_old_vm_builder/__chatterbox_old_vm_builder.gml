/*
	        var _branch_stack = ds_list_create();
	        var _previous_line = -1;
	        var _body_substring_count = ds_list_size(_body_substring_list);
	        for(var _sub = 0; _sub < _body_substring_count; _sub++)
	        {
	            var _substring_array  = _body_substring_list[| _sub];
	            var _string           = _substring_array[0];
	            var _substring_type   = _substring_array[1];
	            var _substring_line   = _substring_array[2];
	            var _substring_indent = _substring_array[3];
                
	            if (_substring_line > _previous_line)
	            {
	                var _branch_top = _branch_stack[| ds_list_size(_branch_stack)-1];
	                while (is_array(_branch_top) && (_substring_indent <= _branch_top[2]))
	                {
	                    ds_list_delete(_branch_stack, ds_list_size(_branch_stack)-1);
	                    if (_branch_top[3]) __chatterbox_new_instruction(_branch_top[0], _branch_top[2]);
	                    _branch_top = _branch_stack[| ds_list_size(_branch_stack)-1];
	                }
	            }
                
	            if (_substring_type == "option")
	            {
                    #region [[option]]
                    
	                var _pos = string_pos("|", _string);
	                if (_pos < 1)
	                {
	                    __chatterbox_new_instruction(__CHATTERBOX_VM_REDIRECT, _substring_indent,
	                                                 [__chatterbox_remove_whitespace(__chatterbox_remove_whitespace(_string, true), false)]);
	                }
	                else
	                {
	                    __chatterbox_new_instruction(__CHATTERBOX_VM_OPTION, _substring_indent,
	                                                 [__chatterbox_remove_whitespace(string_copy(_string, 1, _pos-1), false),
	                                                  __chatterbox_remove_whitespace(string_delete(_string, 1, _pos), true)]);
	                }
                    
                    #endregion
	            }
	            else if (_substring_type == "action")
	            {
	                var _content = __chatterbox_tokenize_action(_string);
                    
                    #region Add instruction based on content array
                    
	                if (_content[0] == "if")
	                {
	                    if (_substring_line > _previous_line)
	                    {
	                        //If-statement on its own on a line
	                        __chatterbox_new_instruction(__CHATTERBOX_VM_IF, _substring_indent, _content);
	                        ds_list_add(_branch_stack, [__CHATTERBOX_VM_ENDIF,            //Type
	                                                    pos-1, //Start position
	                                                    _substring_indent,                //Indentation
	                                                    false]);                          //Automatically create an ENDIF
	                    }
	                    else
	                    {
	                        //If-statement suffixed to another token
	                        __chatterbox_new_instruction(__CHATTERBOX_VM_IF, _substring_indent, _content, pos-1);
	                        ds_list_insert(_branch_stack, ds_list_size(_branch_stack)-1,
	                                                      [__CHATTERBOX_VM_ENDIF,            //Type
	                                                       pos-1, //Start position
	                                                       _substring_indent,                //Indentation
	                                                       true]);                           //Automatically create an ENDIF
	                    }
	                }
	                else if ((_content[0] == "else") || (_content[0] == "elseif") || (_content[0] == "else if"))
	                {
	                    __chatterbox_new_instruction(__CHATTERBOX_VM_ELSEIF, _substring_indent, _content);
	                }
	                else if ((_content[0] == "endif") || (_content[0] == "end if"))
	                {
	                    __chatterbox_new_instruction(__CHATTERBOX_VM_ENDIF, _substring_indent);
	                }
	                else if (_content[0] == "set")
	                {
	                    __chatterbox_new_instruction(__CHATTERBOX_VM_SET, _substring_indent, _content);
	                }
	                else if (_content[0] == "stop")
	                {
	                    __chatterbox_new_instruction(__CHATTERBOX_VM_STOP, _substring_indent);
	                }
	                else if (_content[0] == "wait")
	                {
	                    __chatterbox_new_instruction(__CHATTERBOX_VM_WAIT, _substring_indent);
	                }
	                else if (ds_map_exists(global.__chatterbox_actions, _content[0]))
	                {
	                    __chatterbox_new_instruction(__CHATTERBOX_VM_CUSTOM_ACTION, _substring_indent, _content);
	                }
	                else
	                {
	                    __chatterbox_new_instruction(__CHATTERBOX_VM_GENERIC_ACTION, _substring_indent, [_string]);
	                }
                    
                    #endregion
                    
                    #endregion
	            }
	            else if (string_copy(_string, 1, 2) == "->") //Shortcut
	            {
	                __chatterbox_new_instruction(__CHATTERBOX_VM_SHORTCUT, _substring_indent,
	                                             [__chatterbox_remove_whitespace(string_delete(_string, 1, 2), true)]);
                    
	                ds_list_add(_branch_stack, [__CHATTERBOX_VM_SHORTCUT_END,     //Type
	                                            pos-1, //Start position
	                                            _substring_indent,                //Indentation
	                                            true]);                           //Automatically create a SHORTCUT_END
	            }
	            else //Text
	            {
	                __chatterbox_new_instruction(__CHATTERBOX_VM_TEXT, _substring_indent, [_string]);
	            }
                
	            _previous_line = _substring_line;
	        }
            
	        __chatterbox_new_instruction(__CHATTERBOX_VM_STOP, 0, undefined);
            
	        ds_list_destroy(_branch_stack);
*/