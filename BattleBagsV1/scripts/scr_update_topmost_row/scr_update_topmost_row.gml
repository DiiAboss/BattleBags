/// Updates `global.topmost_row` to the highest row containing a **stationary** gem
function update_topmost_row(_self) {
	
	var width = _self.width;
	var height = _self.height;
	
    global.topmost_row = height - 1; // Start at the bottom

    for (var j = 0; j < height; j++) { // Scan top to bottom
        for (var i = 0; i < width; i++) {
            var gem = _self.grid[i, j];

            // ✅ If there's a valid, stationary gem, update `topmost_row`
            if (gem.type != -1 && !_self.locked[i, j] && !gem.falling) {
                global.topmost_row = j;
                return;
            }
        }
    }
}
