function all_pops_finished() 
{
	var pops_finished = false;
	
    if (ds_list_size(global.pop_list) == 0) pops_finished = true;
	
	for (var i = 0; i < ds_list_size(global.pop_list); i++) {
    var pop_data = ds_list_find_value(global.pop_list, i);
		
	    // Wait for start_delay
	    if (pop_data.timer < pop_data.start_delay) {
	        pop_data.timer++;
			combo_timer = 0;

			var _x = pop_data.x;
	        var _y = pop_data.y;
	        var px = (_x * gem_size) + board_x_offset + offset;
	        var py = (_y * gem_size) + offset + global_y_offset;
			var _color = c_white;
			if (variable_struct_exists(pop_data, "color"))
			{
				_color = pop_data.color;
			}
			
			effect_create_depth(depth + 1, ef_smoke, px, py - 4, 2, _color);
			
	    } else {
	        // Grow effect
	        pop_data.scale += 0.05;
			
			
			
	        // Once scale >= 1.1, pop is done
	        if (pop_data.scale >= 1.1) {
	            var _x = pop_data.x;
	            var _y = pop_data.y;
	            var px = (_x * gem_size) + board_x_offset + offset;
	            var py = (_y * gem_size) + offset + global_y_offset;// + gem_y_offsets[_x, _y];
                    
	            // ✅ Store Gem Object Before Destroying
				if (self.grid[_x, _y] != -1) && (pop_data != -1)
				{
				   
					var gem = self.grid[_x, _y];
				}
				else
				{
					return;
				}
                
                

					if (gem.powerup == POWERUP.MULTI_2X) total_multiplier_next *= 2

		            //Loop Through Multipliers
		            process_powerup(self, _x, _y, gem, total_multiplier_next);
					
					total_blocks_destroyed++;
					// **Destroy the block**
					//destroy_block(self, _x, _y);
                    if !(pop_data.is_big)
                    {
                        destroy_block(self, _x, _y);
                        // ✅ Create Attack Object with Score
                        var attack = instance_create_depth(px, py, depth - 1, obj_player_attack);
                        attack.color = pop_data.color;
                        attack.damage = (pop_data.match_points / pop_data.match_size) * total_multiplier_next; // 🔥 **Apply multiplier to damage!**
                        // ✅ Add accumulated match points to total_points
                        total_points += attack.damage;
                    }
                else {
                    //destroy_block(self, _x, _y);
                }
					
                    // **Create visual effect**
		            effect_create_depth(depth, ef_firework, px, py - 4, 0.5, pop_data.color);

					var _pitch = clamp(0.5 + (0.1 * combo), 0.5, 5);
					var _gain = clamp(0.5 + (0.1 * combo), 0.5, 0.75);
					
                
				audio_play_sound(snd_pop_test_1, 10, false, _gain, 0, _pitch);
				// Remove from pop_list
	            ds_list_delete(global.pop_list, i);
	            i--; 
	            continue;
	        }
	    }
		total_multiplier_next = 1;
	    // Write back updated pop_data

	    ds_list_replace(global.pop_list, i, pop_data);
		
		
		if (pop_data.scale < 1.1) pops_finished = false; 
	}
	return pops_finished;
}


function pop_block_in_queue(_self) 
{
    var gem_size = _self.gem_size;
    var board_x_offset = _self.board_x_offset;
    var offset = gem_size * 0.5;
    var global_y_offset = _self.global_y_offset;
    
    
    if (ds_list_size(global.pop_list) == 0) pops_finished = true;
    
    for (var i = 0; i < ds_list_size(global.pop_list); i++) {
    var pop_data = ds_list_find_value(global.pop_list, i);
        
        // Wait for start_delay
        if (pop_data.timer < pop_data.start_delay) {
            pop_data.timer++;
            combo_timer = 0;

            var _x = pop_data.x;
            var _y = pop_data.y;
            var px = (_x * gem_size) + board_x_offset + offset;
            var py = (_y * gem_size) + offset + global_y_offset;
            
            var _color = c_white;
            if (variable_struct_exists(pop_data, "color"))
            {
                _color = pop_data.color;
            }
            
            effect_create_depth(_self.depth + 1, ef_smoke, px, py - 4, 2, _color);
            
        } else {
            // Grow effect
            pop_data.scale += 0.05;
            
            
            
            // Once scale >= 1.1, pop is done
            if (pop_data.scale >= 1.1) {
                var _x = pop_data.x;
                var _y = pop_data.y;
                var px = (_x * gem_size) + board_x_offset + offset;
                var py = (_y * gem_size) + offset + global_y_offset;// + gem_y_offsets[_x, _y];

                // ✅ Store Gem Object Before Destroying
                if (self.grid[_x, _y] != -1)
                {
                
                    var gem = self.grid[_x, _y];
                }
                else
                {
                    return;
                }
                    
                if (gem.type == BLOCK.MEGA)
                {
                    destroy_block(self, _x, _y);
                    create_block(BLOCK.RANDOM, POWERUP.NONE);
                }
                else {
                    destroy_block(self, _x, _y);
                }
                
                    if (gem.powerup == POWERUP.MULTI_2X) total_multiplier_next *= 2

                    //Loop Through Multipliers
                    process_powerup(self, _x, _y, gem, total_multiplier_next);
                    
                    total_blocks_destroyed++;
                    // **Destroy the block**
                    
                    
                    // **Create visual effect**
                    effect_create_depth(depth, ef_firework, px, py - 4, 0.5, pop_data.color);

                    // ✅ Create Attack Object with Score
                    var attack = instance_create_depth(px, py, depth - 1, obj_player_attack);
                    attack.color = pop_data.color;
                
                    attack.damage = (pop_data.match_points / pop_data.match_size) * total_multiplier_next; // 🔥 **Apply multiplier to damage!**

                    // ✅ Add accumulated match points to total_points
                    total_points += attack.damage;
                    
                    var _pitch = clamp(0.5 + (0.1 * combo), 0.5, 5);
                    var _gain = clamp(0.5 + (0.1 * combo), 0.5, 0.75);
                    
                
                audio_play_sound(snd_pop_test_1, 10, false, _gain, 0, _pitch);
                // Remove from pop_list
                ds_list_delete(global.pop_list, i);
                i--; 
                continue;
            }
        }
        total_multiplier_next = 1;
        // Write back updated pop_data
        ds_list_replace(global.pop_list, i, pop_data);
    }
}

