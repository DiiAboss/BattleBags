function create_mega_block(_width, _height) {
    return {
        x: -1, // Grid X position (top-left)
        y: -1, // Grid Y position (top-left)
        width: _width,
        height: _height,
        type: BLOCK.MEGA,
        falling: true,    // Gem type (e.g., 0 for red, 1 for blue, etc.)
        powerup: -1, // Power-up type (e.g., 0 for bomb, 1 for rainbow, etc.)
        locked: true,     // Whether the gem is locked
        offset_x: 0,       // Horizontal offset for animations
        offset_y: 0,       // Vertical offset for animations
        fall_target: -1,   // Target row for falling animations
		shake_timer: 0,    // New property for shaking effect
		color: c_white,
		fall_delay: 0,
		max_fall_delay: 10, 
		freeze_timer: 0,   // 🔥 New: Countdown to thaw
        frozen: false,      // 🔥 New: Flag for frozen state
		damage: 1,
		combo_multiplier: 1,
		pop_speed: 1,
		explode_on_four: false,
		explode_on_five: false,
		explode_on_six: false,
		popping: false,
		pop_timer: 0,
		group_id: irandom(99999)
    };
}

function spawn_mega_block(_self, _x, _y, _shape_name) {
    if (!ds_map_exists(global.shape_templates, _shape_name)) return;

    var shape = ds_map_find_value(global.shape_templates, _shape_name);
    var shape_width = array_length(shape[0]);
    var shape_height = array_length(shape);

    if (_x < 0 || _x + shape_width > _self.width || _y < 0 || _y + shape_height > _self.height) return;

    var group_id = irandom_range(1, 999999);

    for (var j = 0; j < shape_height; j++) {
        for (var i = 0; i < shape_width; i++) {
            if (shape[j][i] != BLOCK.NONE) {
                var mega_gem = create_block(BLOCK.MEGA);
                mega_gem.is_big = true;
                mega_gem.group_id = group_id;
                mega_gem.big_parent = [_x, _y];
                mega_gem.falling = true;
				mega_gem.fall_delay = 1;
                mega_gem.is_enemy_block = true;
                mega_gem.mega_width = shape_width;
                mega_gem.mega_height = shape_height; // ✅ Store dimensions

                _self.grid[_x + i, _y + j] = mega_gem;
            }
        }
    }
}

function check_adjacent_mega_blocks(_self, _x, _y, _list) {
    var gem = _self.grid[_x, _y];

    // ✅ Only process Mega Blocks
    if (gem.is_big) {
        var parent_x = gem.big_parent[0];
        var parent_y = gem.big_parent[1];
        var parent_block = _self.grid[parent_x, parent_y];

        var big_block_width = parent_block.mega_width;
        var big_block_height = parent_block.mega_height;

        var directions = [
            [-1, 0], [1, 0], [0, -1], [0, 1] // Left, Right, Up, Down
        ];

        // 🔥 Loop through each part of the Mega Block
        for (var bx = 0; bx < big_block_width; bx++) {
            for (var by = 0; by < big_block_height; by++) {
                var block_x = parent_x + bx;
                var block_y = parent_y + by;

                // 🔥 Now check adjacent spaces for **each part** of the Mega Block
                for (var i = 0; i < array_length(directions); i++) {
                    var dx = block_x + directions[i][0];
                    var dy = block_y + directions[i][1];

                    // ✅ Check if within bounds
                    if (dx >= 0 && dx < _self.width && dy >= 0 && dy < _self.height) {
                        var target_block = _self.grid[dx, dy];

                        // ✅ Ensure it's a Mega Block & NOT part of the same group
                        if (target_block.type == BLOCK.MEGA && target_block.group_id != parent_block.group_id) {
                            var already_added = false;
                            
                            // ✅ Check if it's already in the list
                            for (var j = 0; j < ds_list_size(_list); j++) {
                                var existing_pos = ds_list_find_value(_list, j);
                                if (existing_pos[0] == dx && existing_pos[1] == dy) {
                                    already_added = true;
                                    break;
                                }
                            }

                            // ✅ Add to list if it's not already present
                            if (!already_added) {
                                ds_list_add(_list, [dx, dy]);
                            }
                        }
                    }
                }
            }
        }
    }
}





function update_mega_blocks(_self, _list) {
    for (var i = 0; i < ds_list_size(_list); i++) {
        var pos = ds_list_find_value(_list, i);
        var _x = pos[0];
        var _y = pos[1];

        var gem = _self.grid[_x, _y];

        if (gem.type == BLOCK.MEGA) {
            var parent_x = gem.big_parent[0];
            var parent_y = gem.big_parent[1];
            var parent_block = _self.grid[parent_x, parent_y];

            var big_block_width = parent_block.mega_width;
            var big_block_height = parent_block.mega_height;

            //  Loop through each part of the Mega Block
            for (var bx = 0; bx < big_block_width; bx++) {
                for (var by = 0; by < big_block_height; by++) {
                    var block_x = parent_x + bx;
                    var block_y = parent_y + by;

                    // ✅ Transform each piece individually into a new random block
                    _self.grid[block_x, block_y] = create_block(BLOCK.RANDOM);

                    // ✅ Add to pop list (fixed version)
                    var pop_info = {
                        x: block_x,
                        y: block_y,
                        gem_type: BLOCK.RANDOM,
                        timer: 0,
                        start_delay: 5, // 🔥 Give a small delay so we see the effect
                        scale: 1.0,
                        popping: true,
                        powerup: -1,
                        dir: 0,
                        offset_x: 0,
                        offset_y: 0,
                        color: c_red, // 🔥 Make sure we mark them correctly
                        y_offset_global: _self.global_y_offset,
                        match_size: 1,
                        match_points: 10, // Placeholder, adjust as needed
                        bomb_tracker: false,
                        bomb_level: 0,
                        img_number: -1,
                    };

                    ds_list_add(global.pop_list, pop_info);
                    
                    // 🔥 **Create a pop effect**
                    var draw_x = (block_x * 64) + _self.board_x_offset + 32;
                    var draw_y = (block_y * 64) + _self.global_y_offset + 32;
                    effect_create_above(ef_firework, draw_x, draw_y, 1, c_red);
                }
            }
        }
    }
}

function process_mega_blocks(_self, _x, _y) {
    var gem_size = 64; // Grid size
    var offset = 32; // Center offset
    var board_x_offset = _self.board_x_offset;
    var global_y_offset = _self.global_y_offset;

    var gem = _self.grid[_x, _y];

    // 🔥 Only process Mega Blocks
    if (gem.type == BLOCK.MEGA) {
        var parent_x = gem.big_parent[0];
        var parent_y = gem.big_parent[1];
        var parent_block = _self.grid[parent_x, parent_y];

        var big_block_width = parent_block.mega_width;
        var big_block_height = parent_block.mega_height;

        var directions = [
            [-1, 0], [1, 0], [0, -1], [0, 1] // Left, Right, Up, Down
        ];

        // 🔥 Loop through each block of the Mega Block
        for (var bx = 0; bx < big_block_width; bx++) {
            for (var by = 0; by < big_block_height; by++) {
                var block_x = parent_x + bx;
                var block_y = parent_y + by;

                 // 🔥 Now check adjacent spaces for **each part** of the Mega Block
                for (var i = 0; i < array_length(directions); i++) {
                    var dx = block_x + directions[i][0];
                    var dy = block_y + directions[i][1];

                    // ✅ Check if within bounds
                    if (dx >= 0 && dx < _self.width && dy >= 0 && dy < _self.height) {
                        var target_block = _self.grid[dx, dy];

                        // ✅ Determine color: 🔴 Red = empty, 🔵 Blue = occupied
                        var popping_found = (target_block.popping);
						
						
						
                        var draw_x = (dx * gem_size) + board_x_offset + offset + gem.offset_x;
                        var draw_y = (dy * gem_size) + global_y_offset + offset + gem.offset_y;
						
						if (popping_found)
						{
							if target_block.group_id != parent_block.group_id
							{
								//  Loop through each part of the Mega Block
					            for (var bx = 0; bx < big_block_width; bx++) {
					                for (var by = 0; by < big_block_height; by++) {
					                    var block_x = parent_x + bx;
					                    var block_y = parent_y + by;

					                    // ✅ Transform each piece individually into a new random block
					                    _self.grid[block_x, block_y] = create_block(BLOCK.RANDOM);

					                    //// ✅ Add to pop list (fixed version)
					                    //var pop_info = {
					                    //    x: block_x,
					                    //    y: block_y,
					                    //    gem_type: BLOCK.RANDOM,
					                    //    timer: 0,
					                    //    start_delay: 5, // 🔥 Give a small delay so we see the effect
					                    //    scale: 1.0,
					                    //    popping: true,
					                    //    powerup: -1,
					                    //    dir: 0,
					                    //    offset_x: 0,
					                    //    offset_y: 0,
					                    //    color: c_red, // 🔥 Make sure we mark them correctly
					                    //    y_offset_global: _self.global_y_offset,
					                    //    match_size: 1,
					                    //    match_points: 10, // Placeholder, adjust as needed
					                    //    bomb_tracker: false,
					                    //    bomb_level: 0,
					                    //    img_number: -1,
					                    //};

					                    //ds_list_add(global.pop_list, pop_info);
                    
					                    // 🔥 **Create a pop effect**
					                    var draw_x = (block_x * 64) + _self.board_x_offset + 32;
					                    var draw_y = (block_y * 64) + _self.global_y_offset + 32;
					                    effect_create_above(ef_firework, draw_x, draw_y, 1, c_red);
					                }
					            }
							}
						}                   
	                }
	            }
	        }
	    }
	}
}


function debug_draw_mega_block_checks(_self, _x, _y) {
    var gem_size = 64; // Grid size
    var offset = 32; // Center offset
    var board_x_offset = _self.board_x_offset;
    var global_y_offset = _self.global_y_offset;

    var gem = _self.grid[_x, _y];

    // 🔥 Only process Mega Blocks
    if (gem.is_big) {
        var parent_x = gem.big_parent[0];
        var parent_y = gem.big_parent[1];
        var parent_block = _self.grid[parent_x, parent_y];

        var big_block_width = parent_block.mega_width;
        var big_block_height = parent_block.mega_height;

        var directions = [
            [-1, 0], [1, 0], [0, -1], [0, 1] // Left, Right, Up, Down
        ];

        // 🔥 Loop through each block of the Mega Block
        for (var bx = 0; bx < big_block_width; bx++) {
            for (var by = 0; by < big_block_height; by++) {
                var block_x = parent_x + bx;
                var block_y = parent_y + by;

                 // 🔥 Now check adjacent spaces for **each part** of the Mega Block
                for (var i = 0; i < array_length(directions); i++) {
                    var dx = block_x + directions[i][0];
                    var dy = block_y + directions[i][1];

                    // ✅ Check if within bounds
                    if (dx >= 0 && dx < _self.width && dy >= 0 && dy < _self.height) {
                        var target_block = _self.grid[dx, dy];

                        // ✅ Determine color: 🔴 Red = empty, 🔵 Blue = occupied
                        var color = (target_block.popping) ? c_red : c_blue;
						
						
						
                        var draw_x = (dx * gem_size) + board_x_offset + offset + gem.offset_x;
                        var draw_y = (dy * gem_size) + global_y_offset + offset + gem.offset_y;
						if (color == c_red)
						{
							if target_block.group_id != parent_block.group_id
						{
							draw_rectangle(draw_x - 8, draw_y - 8, draw_x + 8, draw_y + 8, false);
							//effect_create_above(ef_firework, draw_x, draw_y, 1, c_red);
						}
						}
                        draw_set_color(color);

                        
						
						draw_set_color(c_white);
                    
	                }
	            }
	        }
	    }
	}
}
    
function process_all_mega_blocks(_self)
{  
    var width = _self.width;
    var bottom_row = _self.bottom_playable_row;
    for (var _x = 0; _x < width; _x++)
    {
        for (var _y = 0; _y < bottom_playable_row; _y++)
        {
            process_mega_blocks(_self, _x, _y);
        }
    }
    
}
