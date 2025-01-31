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

// 🛑 NEW GAME OVER CHECK 🛑
function check_game_over(_self) {
    if (global.topmost_row <= 0) { // Blocks have reached the top
        var blocks_destroyed = 0;
        
        // 🔥 Destroy the entire top row
        for (var i = 0; i < width; i++) {
            if (_self.grid[i, 0].type != -1 && _self.combo > 0) { 
                destroy_block(_self, i, 0); // Call existing destroy function
                blocks_destroyed++;
            }
        }

        // 💔 Reduce health by the number of destroyed blocks
        player_health -= blocks_destroyed;
        global.grid_shake_amount = 10; // Set shake amount on damage
		
        // ⚠️ If health reaches zero, trigger game over
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