function all_pops_finished(player) 
{
	var pops_finished = false;
	var pop_list      = player.pop_list;
    var pop_list_size = ds_list_size(player.pop_list);
    
    if (pop_list_size <= 0)
    {   
        pops_finished = true;
        return pops_finished;  
    } 
	
	for (var i = 0; i < pop_list_size; i++) {
        
        var pop_data = ds_list_find_value(pop_list, i);
		if !(pop_data) return true;
        
        var block = player.grid[pop_data.x, pop_data.y];
        if (block.shake_timer) > 0
        {
            block.shake_timer--;
            continue;
        }
        else
        
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

			
	    } else {
	        // Grow effect
            
	        pop_data.scale += 00.5;
			
			
	        // Once scale >= 1.1, pop is done
	        if (pop_data.scale >= 1.1) {
	            var _x = pop_data.x;
	            var _y = pop_data.y;
	            var px = (_x * gem_size) + board_x_offset + offset;
	            var py = (_y * gem_size) + offset + global_y_offset;// + gem_y_offsets[_x, _y];
                
                if _x < 0 || _y < 0 return; 
                    
                
	            // ✅ Store Gem Object Before Destroying
				if (block == -1) && (pop_data == -1) return;
                
                var block_pop_timer = block.pop_timer;
                if (block.powerup == POWERUP.MULTI_2X) total_multiplier_next *= 2

                //Loop Through Multipliers
                process_powerup(player, _x, _y, block, total_multiplier_next);
                
                total_blocks_destroyed++;
                // **Destroy the block**
                //destroy_block(self, _x, _y);
                if !(pop_data.is_big)
                {
                    var new_block = destroy_block(player, _x, _y);
                    //new_block.pop_timer = block_pop_timer;
                    if !(new_block) return;
                    new_block.popping = true;
                    
                    // ✅ Create Attack Object with Score
                    var attack = instance_create_depth(px, py, player.depth - 1, obj_player_attack);
                    attack.color = pop_data.color;
                    attack.damage = (pop_data.match_points / pop_data.match_size) * total_multiplier_next; // 🔥 **Apply multiplier to damage!**
                    // ✅ Add accumulated match points to total_points
                    total_points += attack.damage;
                }
                
                if (player.color_bomb_enabled > -1 && pop_data.match_size >= 5)
                {
                    player.grid[_x, _y] = create_block(player, BLOCK.COLOR_BOMB);
                }
              
                else {
                  //destroy_block(self, _x, _y);
                }
                  
                objective_progress(OBJECTIVE_TYPE.BREAK_COLOR, pop_data.gem_type);
                
                //for (var _o = 0; _o < array_length(obj_objective_manager.objectives); _o++)
                //{
                    //if (pop_data.type == obj_objective_manager.objectives[_o])
                    //{
                        //
                    //}
                //}
                
                
                    // **Create visual effect**
		            //effect_create_depth(depth, ef_firework, px, py - 4, 0.5, pop_data.color);

                var _pitch = clamp(0.5 + (0.1 * player.combo), 0.5, 5);
                var _gain  = clamp(0.5 + (0.1 * player.combo), 0.5, 0.75);
					
                
				audio_play_sound(snd_pop_test_1, 10, false, _gain, 0, _pitch);
				// Remove from pop_list
	            ds_list_delete(player.pop_list, i);
	            i--; 
	            continue;
	        }
	    }
		total_multiplier_next = 1;
	    // Write back updated pop_data

	    ds_list_replace(player.pop_list, i, pop_data);
		
		
		if (pop_data.scale < 1.1) pops_finished = false; 
	}
	return pops_finished;
}


function pop_block_in_queue(_self) 
{
    var gem_size         = _self.gem_size;
    var board_x_offset   = _self.board_x_offset;
    var offset           = gem_size * 0.5;
    var global_y_offset  = _self.global_y_offset;
    var pop_list         = _self.pop_list;
    var pop_list_size    = ds_list_size(_self.pop_list);
    
    if (pop_list_size == 0) pops_finished = true;
    
    for (var i = 0; i < pop_list_size; i++) {
    var pop_data = ds_list_find_value(_self.pop_list, i);
        
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
            
            //effect_create_depth(_self.depth + 1, ef_smoke, px, py - 4, 2, _color);
            
        } else {
            // Grow effect
            pop_data.scale += 0.05;
            
            
            
            // Once scale >= 1.1, pop is done
            if (pop_data.scale >= 1.1) {
                var _x = pop_data.x;
                var _y = pop_data.y;
                var px = (_x * gem_size) + board_x_offset + offset;
                var py = (_y * gem_size) + offset + global_y_offset;// + gem_y_offsets[_x, _y];
                
                var type = pop_data.gem_type;
                
                
                //objective_progress(OBJECTIVE_TYPE.BREAK_COLOR, type);
                
                //// ✅ Store Gem Object Before Destroying
                //if (self.grid[_x, _y] != -1)
                //{
                
                    var gem = _self.grid[_x, _y];
                //}
                //else
                //{
                    //return;
                //}
                    
                if (gem.type == BLOCK.MEGA)
                {
                    destroy_block(_self, _x, _y);
                    create_block(_self, BLOCK.RANDOM, POWERUP.NONE);
                }
                else {
                    destroy_block(_self, _x, _y);
                }
                
                    if (gem.powerup == POWERUP.MULTI_2X) total_multiplier_next *= 2

                    //Loop Through Multipliers
                    process_powerup(_self, _x, _y, gem, total_multiplier_next);
                    
                    total_blocks_destroyed++;
                    // **Destroy the block**
                    
                    
                    // **Create visual effect**
                    //effect_create_depth(depth, ef_firework, px, py - 4, 0.5, pop_data.color);

                    // ✅ Create Attack Object with Score
                    var attack    = instance_create_depth(px, py, _self.depth - 1, obj_player_attack);
                    attack.color  = pop_data.color;
                
                    attack.damage = (pop_data.match_points / pop_data.match_size) * total_multiplier_next; // 🔥 **Apply multiplier to damage!**

                    // ✅ Add accumulated match points to total_points
                    total_points += attack.damage;
                    
                    var _pitch = clamp(0.5 + (0.1 * _self.combo), 0.5, 5);
                    var _gain  = clamp(0.5 + (0.1 * _self.combo), 0.5, 0.75);
                    
                
                audio_play_sound(snd_pop_test_1, 10, false, _gain, 0, _pitch);
                // Remove from pop_list
                ds_list_delete(_self.pop_list, i);
                i--; 
                continue;
            }
        }
        total_multiplier_next = 1;
        // Write back updated pop_data
        ds_list_replace(_self.pop_list, i, pop_data);
    }
}

