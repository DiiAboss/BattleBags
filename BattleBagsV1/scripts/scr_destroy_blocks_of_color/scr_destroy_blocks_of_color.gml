/// @function destroy_blocks_of_color
/// @param {BLOCK} block_color - The color to destroy

function destroy_blocks_of_color(block_color) {

    // Shortcuts
    var grid_width  = obj_game_control.width;
    var grid_height = obj_game_control.bottom_playable_row;
    
    var total_blocks_destroyed = 0;
    var blocks_to_pop = [];

    // Loop through the entire grid
    for (var _x = 0; _x < grid_width; _x++) {
        for (var _y = 0; _y < grid_height; _y++) {
            var gem = obj_game_control.grid[_x, _y];

            if (gem.type == block_color && !gem.popping && !gem.falling) {
                array_push(blocks_to_pop, [_x, _y]);
            }
        }
    }

    // Loop through blocks collected and push into global.pop_list
    var total_match_points = calculate_match_points(obj_game_control, array_length(blocks_to_pop));

    for (var i = 0; i < array_length(blocks_to_pop); i++) {
        var cx = blocks_to_pop[i][0];
        var cy = blocks_to_pop[i][1];
        var gem = obj_game_control.grid[cx, cy];

        var pop_info = {
            x: cx,
            y: cy,
            gem_type: gem.type,
            timer: 0,
            start_delay: 30 + (i * 2), // Staggered delay effect
            scale: 1.0,
            bomb_tracker: false,
            bomb_level: -1,
            offset_x: gem.offset_x,
            offset_y: gem.offset_y,
            color: gem.color,
            y_offset_global: obj_game_control.global_y_offset,
            match_size: 1,
            match_points: total_match_points,
            img_number: gem.img_number,
            powerup: gem.powerup,
            is_big: false,
        };

        gem.popping = true;
        gem.pop_timer = pop_info.start_delay;

        // Add to global pop list
        ds_list_add(global.pop_list, pop_info);

        total_blocks_destroyed++;
    }

    return total_blocks_destroyed;
}


