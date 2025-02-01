//function activate_bomb_gem(_self, _x, _y) {
//    var blocks_destroyed = 0; // ✅ Count destroyed blocks

//    for (var i = _x - 1; i <= _x + 1; i++) {
//        for (var j = _y - 1; j <= _y + 1; j++) {
//            // ✅ Ensure within grid bounds & is a valid gem
//            if (i >= 0 && i < _self.width && j >= 0 && j < _self.height && _self.grid[i, j].type != -1) {
				
//				blocks_destroyed++; // ✅ Increase count
//				points_awarded = calculate_match_points(self, blocks_destroyed);
		
//		        // ✅ Mark block for destruction
//		        var pop_info = {
//		            x: i,
//		            y: j,
//		            gem_type: _self.grid[i, j].type,
//		            timer: 0,
//		            start_delay: max(abs(i - _x), abs(j - _y)) * 5, // Wave effect
//		            scale: 1.0,
//		            popping: true,
//		            powerup: _self.grid[i, j].powerup,
//		            offset_x: _self.grid[i, j].offset_x,
//		            offset_y: _self.grid[i, j].offset_y,
//		            color: _self.grid[i, j].color,
//		            y_offset_global: _self.global_y_offset,
//					match_size: blocks_destroyed, // ✅ Store the match size
//					match_points: points_awarded,			
//		        };

//		        _self.grid[i, j].popping = true;
//		        _self.grid[i, j].pop_timer = 0;

//				ds_list_add(global.pop_list, pop_info);

				
//                destroy_block(_self, i, j); // ✅ Destroy block
//                blocks_destroyed += 1; // ✅ Track destroyed blocks
//            }
//        }
//    }

//    // ✅ Award points based on blocks destroyed
//    if (blocks_destroyed > 0) {
//        var points_awarded = calculate_match_points(_self, blocks_destroyed);
//        _self.total_points += points_awarded;
//    }
//}


/// Helper: Create pop info for a bomb‐exploded cell
function create_pop_info(_self, cell_x, cell_y, origin_x, origin_y, blocks_destroyed, match_points, bomb_tracker, bomb_level) {
    var wave_multiplier = 5;
    return {
         x: cell_x,
         y: cell_y,
         gem_type: _self.grid[cell_x, cell_y].type,
         timer: 0,
         start_delay: max(abs(cell_x - origin_x), abs(cell_y - origin_y)) * wave_multiplier,
         scale: 1.0,
         popping: true,
         powerup: _self.grid[cell_x, cell_y].powerup,
         offset_x: _self.grid[cell_x, cell_y].offset_x,
         offset_y: _self.grid[cell_x, cell_y].offset_y,
         color: _self.grid[cell_x, cell_y].color,
         y_offset_global: _self.global_y_offset,
         match_size: blocks_destroyed,   // Save how many blocks were destroyed so far
         match_points: match_points,       // Total points for this explosion
         bomb_tracker: true,               // Flag to mark this pop as bomb‐generated
         bomb_level: bomb_level
    };
}

function get_bomb_start_level() {
    // Ensure the upgrade exists before retrieving it
    if (ds_map_exists(global.upgrades, UPGRADE.BOMB_START_LEVEL)) {
        return 1 + ds_map_find_value(global.upgrades, UPGRADE.BOMB_START_LEVEL);
    }
    return 1; // Default level if the upgrade hasn't been unlocked yet
}


/// Bomb explosion function
function activate_bomb_gem(_self, _x, _y, _bomb_level = -1) {
    var blocks_destroyed = 0;
    var total_match_points = 0;
    var gem_size = _self.gem_size;
    var _color = c_white;
    
    var bomb_level = get_bomb_start_level();
    
    // --- Pattern A: Cross pattern for level 1 ---
    if (bomb_level == 1) {
        var coords = [
           { x: _x,     y: _y },
           { x: _x - 1, y: _y },
           { x: _x + 1, y: _y },
           { x: _x,     y: _y - 1 },
           { x: _x,     y: _y + 1 }
        ];
        for (var k = 0; k < array_length(coords); k++) {
            var cx = coords[k].x;
            var cy = coords[k].y;
            if (cx >= 0 && cx < _self.width && cy >= 0 && cy < _self.height &&
                _self.grid[cx, cy].type != -1) {
                
                blocks_destroyed++;
                total_match_points += calculate_match_points(_self, 1);
                
                // ✅ Make sure **ALL AFFECTED BLOCKS** have bomb_tracker enabled
                _self.grid[cx, cy].bomb_tracker = true;
                _self.grid[cx, cy].popping = true;
                _self.grid[cx, cy].pop_timer = 20;
                
                var pop_info = create_pop_info(_self, cx, cy, _x, _y, blocks_destroyed, total_match_points, true, bomb_level);
                ds_list_add(global.pop_list, pop_info);

                _color = _self.grid[cx, cy].color;
                destroy_block(_self, cx, cy);
            }
        }
    }
    // --- Pattern B: Square explosion for level >= 2 ---
    else {
        var size = bomb_level + 1;
        var half = floor(size / 2);
        for (var i = _x - half; i <= _x + half; i++) {
            for (var j = _y - half; j <= _y + half; j++) {
                if (i >= 0 && i < _self.width && j >= 0 && j < _self.height &&
                    _self.grid[i, j].type != -1) {

                    blocks_destroyed++;
                    total_match_points += calculate_match_points(_self, 1);

                    // ✅ Ensure **ALL AFFECTED BLOCKS** get bomb_tracker!
                    _self.grid[i, j].bomb_tracker = true;
                    _self.grid[i, j].popping = true;
                    _self.grid[i, j].pop_timer = 20;
                    
                    var pop_info = create_pop_info(_self, i, j, _x, _y, blocks_destroyed, total_match_points, true, bomb_level);
                    ds_list_add(global.pop_list, pop_info);

                    _color = _self.grid[i, j].color;
                    destroy_block(_self, i, j);
                }
            }
        }
    }

    // --- Create a visual explosion effect at the center ---
    if (blocks_destroyed > 0) {
        var center_x = (_x * gem_size) + board_x_offset + (gem_size / 2);
        var center_y = (_y * gem_size) + offset + _self.global_y_offset + (gem_size / 2);
        effect_create_depth(_self.depth, ef_explosion, center_x, center_y, 1, _color);
    }
    
    // --- Award points based on blocks destroyed ---
    if (blocks_destroyed > 0) {
        var points_awarded = calculate_match_points(_self, blocks_destroyed);
        _self.total_points += points_awarded;
    }
}
