
function check_game_over(_self) 
{
    
    // Do nothing if the combo is active
    if (_self.combo == 0)
	{
		if (_self.lose_life_timer < _self.lose_life_max_timer)
		{
			_self.lose_life_timer += 1;
		}
		else
		{  
		    var blocks_destroyed = 0;
		    // Define the top-of-screen threshold (0 means anything at or above y = 0 counts)
		    var top_row = _self.top_playable_row;
            var width = _self.width;
            
			for (var _x = 0; _x < width; _x++) {
				for (var _y = 0; _y < top_row; _y++) {
					var gem = _self.grid[_x, _y];
                        if (!gem.falling && gem.fall_delay < gem.max_fall_delay && !gem.is_enemy_block) 
                        {
                            blocks_destroyed++;
                        }
				}
			}
    
		    // If we destroyed any blocks, subtract that many from player health
		    if (blocks_destroyed > 0) {
		        player_health -= _self.health_per_heart;
		        global.grid_shake_amount = 10; // Trigger a shake effect
		        if (player_health <= 0) {
		            trigger_final_game_over(_self);
		        }
				
				_self.lose_life_timer = 0;	
		    }
		}
	}
	else
	{
		if (_self.lose_life_timer > 0)
		{
			_self.lose_life_timer -= 1;
		}
		else
		{
			_self.lose_life_timer = 0;
		}
			
	}
}


function trigger_final_game_over(_self) {
    // ✅ Prevent duplicate triggers
    if (_self.game_over_state) return;

    _self.game_over_state = true;
    _self.game_over_timer = 0;
    _self.game_over_pop_delay = 20; // Start slow
    ds_list_clear(_self.game_over_popping);

    var width = _self.width;
    var bottom_row = _self.bottom_playable_row;
    var top_row = _self.top_playable_row;

    // ✅ Add all blocks to the pop queue in order (top-left to bottom-right)
    for (var _y = top_row; _y <= bottom_row; _y++) {
        for (var _x = 0; _x < width; _x++) {
            var block = _self.grid[_x, _y];

            if (block.type != BLOCK.NONE) {
                // ✅ Remove powerups, set to game-over sprite
                block.powerup = POWERUP.NONE;
                block.type = BLOCK.GAME_OVER; 

                // ✅ Add block to pop queue with increasing delays
                var pop_data = {
                    x: _x,
                    y: _y,
                    pop_delay: _self.game_over_pop_delay
                };
                ds_list_add(_self.game_over_popping, pop_data);
                _self.game_over_pop_delay -= 1; // Speed up as we go
            }
        }
    }
}



function legacy_game_over()
{
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
}
