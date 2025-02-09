function destroy_blocks_in_direction_from_point(_self, start_x, start_y, _dir_x, _dir_y, steps = 3) {
    var width = _self.width;
    var height = _self.height;
    var blocks_destroyed = 0;
    var points_awarded = 0;

    // ✅ Start at the given position
    var i = start_x;
    var j = start_y;
	var _steps = 0;

	
	// ✅ Move in the given direction
	while (_steps < steps && i >= 0 && i < width && j >= 1 && j < height) {
	    var gem = _self.grid[i, j];

	    if (i < 0 || i > width) {
	        break; // Stop if an empty space or already popping gem is encountered
	    }

	    blocks_destroyed++;

	    // ✅ Calculate points for this destruction
	    points_awarded = calculate_match_points(_self, blocks_destroyed);

	    // ✅ Mark block for delayed destruction
	    var pop_info =  create_pop_info(_self, gem, i, j, start_x, start_y, blocks_destroyed, points_awarded);
	
	    gem.popping = true;
	    gem.pop_timer = 0;
		
		//if (gem.type == BLOCK.BLACK)
		//{
		//	grid[i, j] = create_block(BLOCK.RANDOM);
		//}
		//else
		
		
		if (gem.type != BLOCK.NONE)
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
