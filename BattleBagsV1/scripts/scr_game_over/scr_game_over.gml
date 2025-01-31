// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
/// Simple Game Over logic
//function game_over() {
//    show_message("Game Over!");
//	game_restart();
//    // Additional logic can be added here
//}

//function check_game_over(_self) {
	
//	var width = _self.width;
	
//    // 1) Skip game over if there's ANY locked gem in row 0
//    for (var i = 0; i < width; i++) {
//        if (_self.grid[i, 0] != -1 && _self.grid[i, 0].falling) {
//            return; 
//        }
//    }

//    // 2) If the loop completes, no locked gems at top row
//    //    Then if row 0 has a gem, cause game over
//    for (var i = 0; i < width; i++) {
//        // FIX SYNTAX: Add parentheses around the entire condition
//        if ((_self.grid[i, 0] != -1) && (!_self.grid[i, 0].falling)) {
//            //game_over();
//            return;
//        }
//    }
//}

function check_game_over(_self) {
    // Do nothing if the combo is active
    if (_self.combo > 0) return;
    
    var blocks_destroyed = 0;
    // Define the top-of-screen threshold (0 means anything at or above y = 0 counts)
    var threshold = 0;
    
    // Loop over all rows (or you could stop at a certain row)
    for (var j = 0; j < _self.height; j++) {
        // Compute the effective y position of row j
        var effective_y = j * gem_size + global_y_offset;
        // If the row’s effective position is above (or at) our threshold…
        if (effective_y <= threshold) {
            for (var i = 0; i < _self.width; i++) {
                var gem = _self.grid[i, j];
                // Only process valid, non-falling, fully settled blocks
                if (gem.type != -1 && !gem.falling && gem.fall_delay == 0) {
                    destroy_block(_self, i, j); // Destroy the block
                    blocks_destroyed++;
                }
            }
        }
    }
    
    // If we destroyed any blocks, subtract that many from player health
    if (blocks_destroyed > 0) {
        player_health -= blocks_destroyed;
        global.grid_shake_amount = 10; // Trigger a shake effect
        
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