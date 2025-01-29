/// @description Change all occupied cells in a given row to a single color (gem type).
/// @param _self     The calling object
/// @param rowIndex  The row index (0..height-1)
/// @param newColor  The gem type or color index you want to apply
function colorize_row(_self, rowIndex, newColor) {
	
	var width = _self.width;
	var height = _self.height;
	
    // Safety check: if 'rowIndex' is outside the grid, do nothing
    if (rowIndex < 0 || rowIndex >= height) {
        return;
    }

    // Iterate each column in this row
    for (var col = 0; col < width; col++) {
        // If this cell is occupied (not -1), set it to newColor
        //if (_self.grid[col, rowIndex].type != -1) {
            _self.grid[col, rowIndex].type = newColor; 
        //}
    }
}