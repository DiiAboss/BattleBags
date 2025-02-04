
function check_game_over(_self) {
    // Do nothing if the combo is active
    if (_self.combo > 0) return;
    
    var blocks_destroyed = 0;
    // Define the top-of-screen threshold (0 means anything at or above y = 0 counts)
    var threshold = 0;
    
    //// Loop over all rows (or you could stop at a certain row)
    //for (var j = 0; j < _self.height; j++) {
    //    // Compute the effective y position of row j
    //    var effective_y = j * gem_size + global_y_offset;
    //    // If the row’s effective position is above (or at) our threshold…
    //    if (effective_y <= threshold) {
    //        for (var i = 0; i < _self.width; i++) {
    //            var gem = _self.grid[i, j];
    //            // Only process valid, non-falling, fully settled blocks
    //            if (gem.type != -1 && !gem.falling && gem.fall_delay == 0) {
    //                destroy_block(_self, i, j); // Destroy the block
    //                blocks_destroyed++;
    //            }
    //        }
    //    }
    //}
	
	for (var i = 0; i < _self.width; i++) {
		var j = 0;
		var gem = _self.grid[i, j];
		if (gem.type != -1 && !gem.falling && gem.fall_delay == 0) {
            grid[i, j] = create_gem(BLOCK.NONE);
            blocks_destroyed++;
        }
	}
    
    // If we destroyed any blocks, subtract that many from player health
    if (blocks_destroyed > 0) {
        player_health -= 4;
        global.grid_shake_amount = 10; // Trigger a shake effect
		blocks_destroyed = 0;
        
        if (player_health <= 0) {
            trigger_final_game_over();
        }
    }
}


// 💀 Final Game Over Function
function trigger_final_game_over() {
    show_message("Game Over! Your health reached 0.");
    game_restart(); // Or transition to a game over screen
}