/// @description Change all occupied cells in a given column to a single color (gem type).
/// @param _self       The calling object
/// @param colIndex  The column index (0..width-1)
/// @param newColor  The gem type or color index you want to apply
function colorize_column(_self, colIndex, newColor) {
    
	var width = _self.width;
	var height = _self.height;
	
    // Safety check: ensure 'colIndex' is in range
    if (colIndex < 0 || colIndex >= width) {
        return;
    }
    
    // Loop through each row in this column
    for (var row = 0; row < height; row++) {
        // If the cell is occupied (not -1), set it to 'newColor'
        if (_self.grid[colIndex, row].type != -1) {
            _self.grid[colIndex, row].type = newColor;
        }
    }
}