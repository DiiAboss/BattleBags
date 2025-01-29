// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
/// Simple Game Over logic
function game_over() {
    show_message("Game Over!");
    // Additional logic can be added here
}

function check_game_over(_self) {
	
	var width = _self.width;
	
    // 1) Skip game over if there's ANY locked gem in row 0
    for (var i = 0; i < width; i++) {
        if (_self.grid[i, 0] != -1 && _self.locked[i, 0]) {
            return; 
        }
    }

    // 2) If the loop completes, no locked gems at top row
    //    Then if row 0 has a gem, cause game over
    for (var i = 0; i < width; i++) {
        // FIX SYNTAX: Add parentheses around the entire condition
        if ((_self.grid[i, 0] != -1) && (!_self.locked[i, 0])) {
            //game_over();
            return;
        }
    }
}