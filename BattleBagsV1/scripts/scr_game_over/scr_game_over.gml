
function check_game_over(_self) 
{
    // Do nothing if the combo is active
    if (_self.combo == 0)
	{
		if (lose_life_timer < lose_life_max_timer)
		{
			lose_life_timer += 1;
		}
		else
		{  
		    var blocks_destroyed = 0;
		    // Define the top-of-screen threshold (0 means anything at or above y = 0 counts)
		    var top_row = _self.top_playable_row;
	
			for (var i = 0; i < _self.width; i++) {
				for (var j = 0; j < top_row; j++) {
					var gem = _self.grid[i, j];
					if (are_playable_blocks_settled(self))  {
			            //grid[i, 0] = create_block(BLOCK.NONE);
			            blocks_destroyed++;
			        }
				}
			}
    
		    // If we destroyed any blocks, subtract that many from player health
		    if (blocks_destroyed > 0) {
		        player_health -= _self.health_per_heart;
		        global.grid_shake_amount = 10; // Trigger a shake effect
		        if (player_health <= 0) {
		            trigger_final_game_over();
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


// 💀 Final Game Over Function
function trigger_final_game_over() {
    show_message("Game Over! Your health reached 0.");
	
	ds_list_destroy(global.upgrades_list);
	
    game_restart(); // Or transition to a game over screen
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
