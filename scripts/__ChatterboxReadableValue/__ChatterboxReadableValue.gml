// Feather disable all

function __ChatterboxReadableValue(_value)
{
    if (is_string(_value))
    {
        return "\"" + _value + "\"";
    }
    else if (is_undefined(_value))
    {
        return "<undefined>";
    }
    else if (is_bool(_value))
    {
        return _value? "<true>" : "<false>";
    }
    else
    {
        return string(_value);
    }
}