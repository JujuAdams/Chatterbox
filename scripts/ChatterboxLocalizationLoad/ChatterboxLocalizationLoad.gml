/// Loads a localisation CSV file created by ChatterboxLocalizationBuild()
/// Any text in the base YarnScript file that either has no line hash or whose line hash cannot
/// be found in the localisation CSV will be displayed in the native language. Only one
/// localisation file can be used at once. New localisation is applied the next time a Chatterbox
/// flow function is executed (ChatterboxContinue() etc.)
/// 
/// @param path  Path to the localisation file to use, relative to CHATTERBOX_INCLUDED_FILES_SUBDIRECTORY

function ChatterboxLocalizationLoad(_path)
{
    ds_map_clear(global.__chatterboxLocalisationMap);
    __ChatterboxLocalizationLoad(_path, global.__chatterboxLocalisationMap);
}

function __ChatterboxLocalizationLoad(_path, _map)
{
    var _grid = load_csv(_path); //TODO - Replace with SNAP?
    
    var _filename = "????";
    var _node     = "????";
    var _prefix   = "????:????:";
    
    var _y = 1;
    repeat(ds_grid_height(_grid)-1)
    {
        if (_grid[# 0, _y] != "")
        {
            _filename = _grid[# 0, _y];
            _node     = "????";
            _prefix   = _filename + ":" + _node + ":";
        }
        
        if (_grid[# 1, _y] != "")
        {
            _node   = _grid[# 1, _y];
            _prefix = _filename + ":" + _node + ":";
        }
        
        var _hash = _grid[# 2, _y];
        var _text = _grid[# 3, _y];
        
        if ((_hash != "") && (_text != ""))
        {
            _map[? _prefix + _hash] = _text;
        }
        
        ++_y;
    }
    
    ds_grid_destroy(_grid);
}