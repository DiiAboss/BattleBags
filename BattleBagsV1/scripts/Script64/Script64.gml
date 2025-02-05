    //for (var i = 0; i < width; i++) {
    //    for (var j = 0; j < height; j++) {
    //        if (marked_for_removal[i, j]) {
    //            found_any = true;
    //            grid[i, j].shake_timer = max_shake_timer; // Start shaking effect
				
    //            var gem = grid[i, j];
				
    //            var dx = i - global.lastSwapX;
    //            var dy = j - global.lastSwapY;
    //            var dist = sqrt(dx * dx + dy * dy);
	//			var _start_delay = 5;
				
	//			if (gem.type == BLOCK.BLACK)
	//			{
	//				_start_delay = 20;
	//			}
				
				
    //            var pop_info = {
    //                x: i,
    //                y: j,
    //                gem_type: gem.type,
    //                timer: 0,
    //                start_delay: dist * _start_delay, // Wave effect
    //                scale: 1.0,
    //                popping: true,
    //                powerup: gem.powerup,
	//				dir: gem.dir,
    //                offset_x: gem.offset_x,
    //                offset_y: gem.offset_y,
    //                color: gem.color,
    //                y_offset_global: global_y_offset,
	//				match_size: match_count, // ✅ Store the match size
	//				match_points: total_match_points,
	//				bomb_tracker: false,               // Flag to mark this pop as bomb‐generated
	//				bomb_level: 0
    //            };
				
	//			//target_experience_points += (match_count + combo) + (global.modifier);

    //            grid[i, j].popping = true;
    //            grid[i, j].pop_timer = dist * _start_delay;

    //            ds_list_add(global.pop_list, pop_info);
    //        }
    //    }
    //}4