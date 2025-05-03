function activate_shuffle(player) {
	
	var width = player.board_width;
	var height = player.board_height;
	
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            if (player.grid[i, j] != -1) {
                player.grid[i, j] = create_block(player, BLOCK.RANDOM);
            }
        }
    }
}