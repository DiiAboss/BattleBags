/// Spawns a new row at the bottom (not currently called in this Step)
function spawn_new_row(_self) {
    // Shift all grid values up by one row
	var width = _self.width;
	var height = _self.height;
	
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height - 1; j++) {
			 if (!_self.grid[i, j].popping) { // ✅ Don't overwrite popping gems
            _self.grid[i, j] = _self.grid[i, j + 1];
			 }
        }
    }
    // Add a new random row at the bottom
    for (var i = 0; i < width; i++) {
        _self.grid[i, height - 1] = create_gem(BLOCK.RANDOM);
    }
}