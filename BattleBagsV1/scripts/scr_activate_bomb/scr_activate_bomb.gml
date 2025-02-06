/// Helper: Create pop info for a bomb‐exploded cell
function create_pop_info(_self, cell_x, cell_y, origin_x, origin_y, blocks_destroyed, _match_points, _bomb_tracker, _bomb_level) {
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
    // Ensure the upgrade exists before retrieving it
    //if (ds_list_find_value(global.upgrades, UPGRADE.BOMB_START_LEVEL)) {
    //    return 1 + ds_list_find_value(global.upgrades, UPGRADE.BOMB_START_LEVEL);
    //}
    return 1; // Default level if the upgrade hasn't been unlocked yet
}

function activate_bomb_gem(_self, _x, _y, _bomb_level = -1) {
	// ✅ **Prevent bombs from activating on blank spaces**
    if (_self.grid[_x, _y] == -1 || _self.grid[_x, _y].type == BLOCK.NONE) {
        return; // ❌ Stop function early if the bomb is on an invalid space
    }
	
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

        if (cx >= 0 && cx < _self.width && cy >= 0 && cy < _self.height &&
            _self.grid[cx, cy].type != -1) {
				_self.grid[cx, cy].shake_timer = max_shake_timer * 4;

            var gem = _self.grid[cx, cy];

            if (gem.type == BLOCK.BLACK) {
                ds_list_add(black_blocks_to_transform, [cx, cy]); // ✅ Store black blocks for later transformation
            } else {
                blocks_destroyed++;
                total_match_points += calculate_match_points(_self, 1);
                gem.popping = true;
                //gem.pop_timer = 60;
				
				if (k) = 0
				{
					var pop_info = create_pop_info(_self, cx, cy, _x, _y, blocks_destroyed, total_match_points, true, bomb_level);
				}
				else
				{
					var pop_info = create_pop_info(_self, cx, cy, _x, _y, blocks_destroyed, total_match_points, false, bomb_level);
				}
				ds_list_add(global.pop_list, pop_info);
            }
        }
    }

    // ✅ Transform Black Blocks AFTER pop effects finish
    update_black_blocks(_self, black_blocks_to_transform);
    ds_list_destroy(black_blocks_to_transform);
}
