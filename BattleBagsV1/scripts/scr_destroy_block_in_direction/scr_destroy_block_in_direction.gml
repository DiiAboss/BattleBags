function destroy_blocks_in_direction_from_point(_self, start_x, start_y, _dir_x, _dir_y, steps = 3) {
    var width = _self.width;
    var height = _self.height;
    var blocks_destroyed = 0;
    var points_awarded = 0;
    var bottom_row = _self.bottom_playable_row;
    
    // ✅ Start at the given position
    var i = start_x;
    var j = start_y;
	var _steps = 0;

	
	// ✅ Move in the given direction
	while (_steps < steps && i >= 0 && i < width && j >= 1 && j < height) {
	    var block = _self.grid[i, j];

	    if (i < 0 || i > width) {
	        break; // Stop if an empty space or already popping block is encountered
	    }

	    blocks_destroyed++;

	    // ✅ Calculate points for this destruction
	    points_awarded = calculate_match_points(_self, blocks_destroyed);

	    // ✅ Mark block for delayed destruction
	    var pop_info =  create_pop_info(_self, block, i, j, start_x, start_y, blocks_destroyed, points_awarded);
	
	    block.popping = true;
	    block.pop_timer = 0;
		
		
        // ✅ If it's a BIG BLOCK, transform it into separate blocks
                    if (block.is_big) {
                        
                        var group_id = block.group_id;
                        var dx = i - global.lastSwapX;
                        var dy = j - global.lastSwapY;
                        var dist = sqrt(dx * dx + dy * dy);
                        
                        for (var _i = 0; _i < self.width; _i++) {
                            for (var _j = 0; _j <= bottom_row; _j++) {
                                var other_block = grid[_i, _j];
        
                                if (other_block.group_id == group_id) {
                                    // ✅ Convert each big block part into a small block of the same type
                                    _self.grid[_i, _j] = create_block(block.type);						
                                
                                    // ✅ Send the block to pop_list (Now applies to normal and transformed blocks)
                                    var pop_info = {
                                        x: _i,
                                        y: _j,
                                        gem_type: block.type,
                                        timer: 0,
                                        start_delay: dist * 5, // Wave effect
                                        scale: 1.0,
                                        popping: true,
                                        powerup: block.powerup,
                                        dir: block.dir,
                                        offset_x: block.offset_x,
                                        offset_y: block.offset_y,
                                        color: block.color,
                                        y_offset_global: _self.global_y_offset,
                                        match_size: max(block.mega_width * block.mega_height, 1), // ✅ Store the match size
                                        match_points: max(block.mega_width * block.mega_height, 1) * 1.5,
                                        bomb_tracker: false, // Flag to mark this pop as bomb‐generated
                                        bomb_level: 0,
                                        img_number: block.img_number,
                                        is_big: false,
                                    };
                                
                                    _self.grid[_i, _j].popping   = true;  // Start popping process
                                    _self.grid[_i, _j].pop_timer = dist * 5;
                                    var _pitch = clamp(0.75 + (0.2 * _self.combo), 0.5, 5);
                                    if !(_self.game_over_state)
                                    {
                                        audio_play_sound(snd_pre_bubble_pop_test, 10, false, 0.25, 0, _pitch);
                                    }
                                    
                                    
                                    ds_list_add(global.pop_list, pop_info);
                                }
                            }
                        }
                    }
        
        
        else if (block.type == BLOCK.BLACK)
		{
			grid[i, j] = create_block(BLOCK.RANDOM);
		}
		else
		
		
		if (block.type != BLOCK.NONE)
		{
			ds_list_add(global.pop_list, pop_info);
		}

	    // Move in the given direction
	    i += _dir_x;
	    j += _dir_y;
		
		_steps ++;
	}
	

    // ✅ Add total points from destruction
    _self.total_points += points_awarded;
	
	
	var final_pos_x = (start_x + (_dir_x * steps));
	var final_pos_y = (start_y + (_dir_y * steps));
	
	//
	var final_pos = [final_pos_x, final_pos_y];
		
	var bow_obj = instance_create_depth(_self.board_x_offset + start_x * _self.gem_size + 32, (start_y * _self.gem_size) + _self.global_y_offset + 32, depth-99, obj_bow);
		
	bow_obj.final_pos = final_pos;
	
	return [final_pos_x, final_pos_y];
}
