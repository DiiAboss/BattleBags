/// Helper: Create pop info for a bomb‐exploded cell
function create_bomb_pop_info(_self, cell_x, cell_y, origin_x, origin_y, blocks_destroyed, _match_points, _bomb_tracker, _bomb_level) {
    var wave_multiplier = 15;
    return {
         x: cell_x,
         y: cell_y,
         gem_type: _self.grid[cell_x, cell_y].type,
         timer: 0,
         start_delay: 45,
         scale: 1.0,
         popping: true,
         powerup: _self.grid[cell_x, cell_y].powerup,
         offset_x: _self.grid[cell_x, cell_y].offset_x,
         offset_y: _self.grid[cell_x, cell_y].offset_y,
         color: _self.grid[cell_x, cell_y].color,
         y_offset_global: _self.global_y_offset,
         match_size: blocks_destroyed,   // Save how many blocks were destroyed so far
         match_points: _match_points,       // Total points for this explosion
         bomb_tracker: _bomb_tracker,               // Flag to mark this pop as bomb‐generated
         bomb_level: _bomb_level,
		 img_number: _self.grid[cell_x, cell_y].img_number,
    };
}

function get_bomb_start_level() {
     //Ensure the upgrade exists before retrieving it
    //if (ds_list_find_value(global.upgrades, UPGRADE.BOMB_START_LEVEL)) {
    //    return 1 + ds_list_find_value(global.upgrades, UPGRADE.BOMB_START_LEVEL);
    //}
    return 1; // Default level if the upgrade hasn't been unlocked yet
}

function activate_bomb_gem(_self, _x, _y, _bomb_level = -1) {
	
	// ✅ **Prevent bombs from activating on blank spaces**
    if (_self.grid[_x, _y] == -1 || _self.grid[_x, _y].type == BLOCK.NONE) return; // ❌ Stop function early if the bomb is on an invalid space
	
    var blocks_destroyed = 0;
    var total_match_points = 0;
    var black_blocks_to_transform = ds_list_create(); // ✅ Track black blocks hit by bomb

    var bomb_level = get_bomb_start_level();
    var coords = [];

    if (bomb_level == 1) {
        coords = [
           { x: _x,     y: _y },
           { x: _x - 1, y: _y },
           { x: _x + 1, y: _y },
           { x: _x,     y: _y - 1 },
           { x: _x,     y: _y + 1 }
        ];
    } else {
        var size = bomb_level + 1;
        var half = floor(size / 2);
        for (var i = _x - half; i <= _x + half; i++) {
            for (var j = _y - half; j <= _y + half; j++) {
                coords.push({ x: i, y: j });
            }
        }
    }

    for (var k = 0; k < array_length(coords); k++) {
        var cx = coords[k].x;
        var cy = coords[k].y;
		var bottom_row = _self.bottom_playable_row;

        if (cx >= 0 
		 && cx < _self.width 
		 && cy >= 0 
		 && cy <= bottom_row 
		 && _self.grid[cx, cy].type != BLOCK.NONE) {
			 
			_self.grid[cx, cy].shake_timer = max_shake_timer * 4; // What the hell is the 4 here for?
            var block = _self.grid[cx, cy];

            // ✅ If it's a BIG BLOCK, transform it into separate blocks
            if (block.is_big) {
                
                var group_id = block.group_id;
                var dx = cx - global.lastSwapX;
                var dy = cy - global.lastSwapY;
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
            else
            
            if (block.type == BLOCK.BLACK) {
                ds_list_add(black_blocks_to_transform, [cx, cy]); // ✅ Store black blocks for later transformation
            } else {
                blocks_destroyed++;
                total_match_points += calculate_match_points(_self, 1);
                block.popping = true;
                block.pop_timer = 10;
				
				if (k) = 0
				{
					var pop_info = create_bomb_pop_info(_self, cx, cy, _x, _y, blocks_destroyed, total_match_points, true, bomb_level);
				}
				else
				{
					var pop_info = create_bomb_pop_info(_self, cx, cy, _x, _y, blocks_destroyed, total_match_points, false, bomb_level);
				}
				ds_list_add(global.pop_list, pop_info);
            }
        }
    }

    // ✅ Transform Black Blocks AFTER pop effects finish
    update_black_blocks(_self, black_blocks_to_transform);
    ds_list_destroy(black_blocks_to_transform);
}
