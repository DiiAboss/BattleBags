/// Spawns a new row at the bottom (not currently called in this Step)
function spawn_new_row(player) {
    // Shift all grid values up by one row
	var width = player.board_width;
	var height = player.board_height;
	
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height - 1; j++) {
			 if (!player.grid[i, j].popping) { // ✅ Don't overwrite popping gems
            player.grid[i, j] = player.grid[i, j + 1];
			 }
        }
    }
    // Add a new random row at the bottom
    for (var i = 0; i < width; i++) {
        player.grid[i, height - 1] = create_block(player, BLOCK.RANDOM);
    }
}