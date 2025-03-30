/// Updates `global.topmost_row` to the highest row containing a **stationary** gem
function update_topmost_row(player) {
	
	var width = player.board_width;
	var height = player.board_height;
	
    player.topmost_row = height - 1; // Start at the bottom

    for (var j = 0; j < height; j++) { // Scan top to bottom
        for (var i = 0; i < width; i++) {
            var block = player.grid[i, j];

            // ✅ If there's a valid, stationary gem, update `topmost_row`
            if (block.type != BLOCK.NONE && !player.locked[i, j] && !block.falling && block.fall_delay == 0) {
                player.topmost_row = j;
                return;
            }
        }
    }
}


function update_topmost_row_mp(player) {
    
    var width = player.board_width;
    var height = player.board_height;
    
    player.topmost_row = height - 1; // Start at the bottom

    for (var j = 0; j < height; j++) { // Scan top to bottom
        for (var i = 0; i < width; i++) {
            var gem = player.grid[i, j];

            // ✅ If there's a valid, stationary gem, update `topmost_row`
            if (gem.type != BLOCK.NONE && !gem.falling && gem.fall_delay == 0) {
                player.topmost_row = j;
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
