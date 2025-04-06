/// Helper: Create pop info for a bomb‐exploded cell
function create_bomb_pop_info(player, cell_x, cell_y, origin_x, origin_y, blocks_destroyed, _match_points, _bomb_tracker, _bomb_level) {
    var wave_multiplier = 15;
    var block = player.grid[cell_x, cell_y];
    var bomb_struct = create_block(player, block.type, block.powerup);
    bomb_struct.start_delay = 45;
    bomb_struct.bomb_level = _bomb_level;
    bomb_struct.match_size = blocks_destroyed;
    bomb_struct.match_points = _match_points;
    bomb_struct.bomb_tracker = _bomb_tracker;
    
    return bomb_struct;
}

function get_bomb_start_level() {
     //Ensure the upgrade exists before retrieving it
    //if (ds_list_find_value(global.upgrades, UPGRADE.BOMB_START_LEVEL)) {
    //    return 1 + ds_list_find_value(global.upgrades, UPGRADE.BOMB_START_LEVEL);
    //}
    return 1; // Default level if the upgrade hasn't been unlocked yet
}

function activate_bomb_gem(player, _x, _y, _bomb_level = -1) {
	
	// ✅ **Prevent bombs from activating on blank spaces**
    if (player.grid[_x, _y] == -1 || player.grid[_x, _y].type == BLOCK.NONE) return; // ❌ Stop function early if the bomb is on an invalid space
	
    var blocks_destroyed = 0;
    var total_match_points = 0;
    var black_blocks_to_transform = ds_list_create(); // ✅ Track black blocks hit by bomb
    var width  = player.board_width;
    var height = player.board_height;
    var bottom_row = player.bottom_playable_row;
    
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
    var bomb_size = array_length(coords);
    for (var k = 0; k < bomb_size; k++) {
        var cx = coords[k].x;
        var cy = coords[k].y;
		

        if (cx >= 0 
		 && cx < width
		 && cy >= 0 
		 && cy < bottom_row
		 && player.grid[cx, cy].type != BLOCK.NONE){ 
            
            
            var block = player.grid[cx, cy];
			block.shake_timer = 30; // What the hell is the 4 here for?
            
            
            handle_find_and_destroy_big_block(player, block, bomb_size, total_match_points)
           
            
            if (block.type == BLOCK.BLACK) {
                ds_list_add(black_blocks_to_transform, [cx, cy]); // ✅ Store black blocks for later transformation
            } else {
                blocks_destroyed++;
                total_match_points += calculate_match_points(player, 1);
                block.popping = true;
                block.pop_timer = 10;
                var pop_info = create_pop_info(player, block, cx, cy);
                pop_info.start_delay = k * 5;

				ds_list_add(player.pop_list, pop_info);
            }
        }
    }

    // ✅ Transform Black Blocks AFTER pop effects finish
    //update_black_blocks(_self, black_blocks_to_transform);
    ds_list_destroy(black_blocks_to_transform);
}
