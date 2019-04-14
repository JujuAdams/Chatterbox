/// @param chatterbox
/// @param contentArray

var _chatterbox = argument0;
var _content    = argument1;

var _variables_map = _chatterbox[| __CHATTERBOX.VARIABLES ];

var _resolved_array = array_create(array_length_1d(_content), pointer_null); //Copy the array

var _queue = ds_list_create();
ds_list_add(_queue, 1);
repeat(9999)
{
    if (ds_list_empty(_queue)) break;
    
    var _element_index = _queue[| 0];
    var _element = _content[_element_index];
    
    if (!is_array(_element))
    {
        _resolved_array[_element_index] = _element;
        ds_list_delete(_queue, 0);
    }
    else
    {
        #region Check if all elements have been resolved
        
        var _fully_resolved = true;
        var _element_length = array_length_1d(_element);
        for(var _i = 0; _i < _element_length; _i++)
        {
            var _child_index = _element[_i];
            if (_resolved_array[_child_index] == pointer_null)
            {
                _fully_resolved = false;
                ds_list_insert(_queue, 0, _child_index);
            }
        }
        
        #endregion
        
        if (_fully_resolved)
        {
            if (_element_length == 1)
            {
                _resolved_array[_element_index] = _element[0];
            }
            else if (_element_length == 2)
            {
                #region Resolve unary operators (!variable / -variable)
                
                var _operator = _resolved_array[_element[0]];
                var _value    = _resolved_array[_element[1]];
                
                if (_operator == "!")
                {
                    _resolved_array[_element_index] = !_value;
                }
                else if (_operator == "-")
                {
                    _resolved_array[_element_index] = -_value;
                }
                else
                {
                    show_debug_message("Chatterbox: WARNING! 2-length evaluation element with unrecognised operator: \"" + string(_operator) + "\"");
                    _resolved_array[_element_index] = undefined;
                }
                
                #endregion
            }
            else if (_element_length == 3)
            {
                #region Figure out datatypes and grab variable values
                
                var _a        = _resolved_array[_element[0]];
                var _operator = _resolved_array[_element[1]];
                var _b        = _resolved_array[_element[2]];
                
                var _a_value = __chatterbox_resolve_value(_chatterbox, _a);
                var _a_typeof = typeof(_a_value);
                var _a_scope = global.__chatterbox_scope;
                global.__chatterbox_scope = CHATTERBOX_SCOPE.__INVALID;
                var _b_value = __chatterbox_resolve_value(_chatterbox, _b);
                var _b_typeof = typeof(_b_value);
                
                var _pair_typeof = _a_typeof + ":" + _b_typeof;
                
                #endregion
                
                #region Resolve binary operators
                
                var _result = undefined;
                var _set = false;
                
                if (_a_typeof != _b_typeof)
                {
                    if (_operator != "+") && (_operator != "+=") && (_operator != "==") && (_operator != "!=")
                    {
                        if (CHATTERBOX_ERROR_ON_MISMATCHED_DATATYPE)
                        {
                            show_error("Chatterbox:\nMismatched datatypes\n ", false);
                        }
                        else
                        {
                            show_debug_message("Chatterbox: WARNING! Mismatched datatypes");
                        }
                    }
                }
                
                switch(_operator)
                {
                    case "/": if (_pair_typeof == "number:number") _result = _a_value / _b_value; break;
                    case "*": if (_pair_typeof == "number:number") _result = _a_value * _b_value; break;
                    case "-": if (_pair_typeof == "number:number") _result = _a_value - _b_value; break;
                    case "+":
                        if (!is_undefined(_a_value) && !is_undefined(_b_value))
                        {
                            _result = ((_a_typeof == "string") || (_b_typeof == "string"))? (string(_a_value) + string(_b_value)) : (_a_value + _b_value);
                        }
                    break;
                    
                    case "/=": _set = true; if (_pair_typeof == "number:number") _result = _a_value / _b_value; break;
                    case "*=": _set = true; if (_pair_typeof == "number:number") _result = _a_value * _b_value; break;
                    case "-=": _set = true; if (_pair_typeof == "number:number") _result = _a_value - _b_value; break;
                    case "=":  _set = true;                                      _result =            _b_value; break;
                    case "+=":
                        _set = true;
                        if (!is_undefined(_a_value) && !is_undefined(_b_value))
                        {
                            _result = ((_a_typeof == "string") || (_b_typeof == "string"))? (string(_a_value) + string(_b_value)) : (_a_value + _b_value);
                        }
                    break;
                    
                    case "||": _result = (_pair_typeof == "number:number")? (_a_value || _b_value) : false; break;
                    case "&&": _result = (_pair_typeof == "number:number")? (_a_value && _b_value) : false; break;
                    case ">=": _result = (_pair_typeof == "number:number")? (_a_value >= _b_value) : false; break;
                    case "<=": _result = (_pair_typeof == "number:number")? (_a_value <= _b_value) : false; break;
                    case ">":  _result = (_pair_typeof == "number:number")? (_a_value >  _b_value) : false; break;
                    case "<":  _result = (_pair_typeof == "number:number")? (_a_value <  _b_value) : false; break;
                    case "!=": _result = (_a_typeof == _b_typeof)?          (_a_value != _b_value) : true;  break;
                    case "==": _result = (_a_typeof == _b_typeof)?          (_a_value == _b_value) : false; break;
                }
                
                if (_set)
                {
                    switch(_a_scope)
                    {                   
                        case CHATTERBOX_SCOPE.INTERNAL:   _variables_map[? _a ] = _result;        break;
                        case CHATTERBOX_SCOPE.GML_LOCAL:  variable_instance_set(id, _a, _result); break;
                        case CHATTERBOX_SCOPE.GML_GLOBAL: variable_global_set(_a, _result);       break;
                    }
                }
                
                _resolved_array[_element_index] = _result;
                
                #endregion
            }
            
            ds_list_delete(_queue, 0);
        }
    }
}

ds_list_destroy(_queue);

return _resolved_array[1];