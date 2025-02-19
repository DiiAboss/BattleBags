/// Updates `global.topmost_row` to the highest row containing a **stationary** gem
function update_topmost_row(_self) {
	
	var width = _self.width;
	var height = _self.height;
	
    global.topmost_row = height - 1; // Start at the bottom

    for (var j = 0; j < height; j++) { // Scan top to bottom
        for (var i = 0; i < width; i++) {
            var gem = _self.grid[i, j];

            // ✅ If there's a valid, stationary gem, update `topmost_row`
            if (gem.type != -1 && !_self.locked[i, j] && !gem.falling && gem.fall_delay == 0) {
                global.topmost_row = j;
                return;
            }
        }
    }
}


function any_blocks_above(player, above_row) {
    
    var width = player.board_width;
    var height = player.board_height;
    
    var bottom_row = player.bottom_playable_row;
    
    var check_row = height - 1; // Start at the bottom

    for (var j = 0; j < above_row; j++) { // Scan top to bottom
        for (var i = 0; i < width; i++) {
            var gem = player.grid[i, j];

            // ✅ If there's a valid, stationary gem, update `topmost_row`
            if (gem.type != BLOCK.NONE) {
                return true;
            }
        }
    }
    return false;
}
