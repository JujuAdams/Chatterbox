// Feather disable all
function __ChatterboxLocalizationLoadIntoMap(_path, _map, _read_hash = false)
{
    if (!file_exists(_path))
    {
        __ChatterboxTrace("Warning! CSV file \"", _path, "\" doesn't exist");
        return;
    }
    
    var _grid = load_csv(_path); //TODO - Replace with SNAP?
    
    var _filename = "????";
    var _node     = "????";
    var _prefix   = "????:????:";
    
    var _y = 1;
    repeat(ds_grid_height(_grid)-1)
    {
        if (_grid[# 1, _y] != "")
        {
            _filename = _grid[# 1, _y];
            _node     = "????";
            _prefix   = _filename + ":" + _node + ":";
        }
        
        if (_grid[# 2, _y] != "")
        {
            _node   = _grid[# 2, _y];
            _prefix = _filename + ":" + _node + ":";
        }
        
        var _line_id = _grid[# 3, _y];
        var _text    = _grid[# 5, _y];
        
        if ((_line_id != "") && (_text != ""))
        {
            _map[? _prefix + _line_id] = _text;
            if (_read_hash) _map[? _prefix + _line_id + ":hash"] = _grid[# 4, _y];
        }
        
        ++_y;
    }
    
    ds_grid_destroy(_grid);
}
