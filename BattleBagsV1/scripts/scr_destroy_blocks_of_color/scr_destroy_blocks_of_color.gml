/// @function destroy_blocks_of_color

function destroy_blocks_of_color(player, block_color) {

    // Shortcuts
    var grid_width  = player.board_width;
    var grid_height = player.bottom_playable_row;
    var top_row     = player.top_playable_row;
    var total_blocks_destroyed = 0;
    var blocks_to_pop = [];
    var number_of_block_types = player.numberOfGemTypes;
    
    // Loop through the entire grid
    for (var _x = 0; _x < grid_width; _x++) {
        for (var _y = top_row; _y < grid_height; _y++) {
            var block = player.grid[_x, _y];
            
            if (block.type == block_color) {
                array_push(blocks_to_pop, [_x, _y]);
            }
        }
    }
    
    
    // Loop through blocks collected and push into player.pop_list
    var total_match_points = calculate_match_points(player, array_length(blocks_to_pop));

    for (var i = 0; i < array_length(blocks_to_pop); i++) {
        var cx = blocks_to_pop[i][0];
        var cy = blocks_to_pop[i][1];
        var block = player.grid[cx, cy];
        
        if (block.type == BLOCK.BLACK) {
                 player.grid[cx, cy] = create_block(BLOCK.RANDOM, POWERUP.NONE);//.type = irandom(number_of_block_types - 1); //0 - 7 == 8 block types
                //ds_list_add(global.black_blocks_to_transform, [cx, cy]);
            }
        
        var pop_info = create_pop_info(player, block, cx, cy);
        pop_info.match_points = total_match_points;
        pop_info.match_size   = 1;
        pop_info.start_delay  = 10 + (i * 2);
        
        //var pop_info = {
            //x: cx,
            //y: cy,
            //gem_type: block.type,
            //timer: 0,
            //start_delay: 10 + (i * 2), // Staggered delay effect
            //scale: 1.0,
            //bomb_tracker: false,
            //bomb_level: -1,
            //offset_x: block.offset_x,
            //offset_y: block.offset_y,
            //color: block.color,
            //y_offset_global: player.global_y_offset,
            //match_size: 1,
            //match_points: total_match_points,
            //img_number: block.img_number,
            //powerup: block.powerup,
            //is_big: false,
        //};

        send_pop_info_to_pop_list(player, pop_info, cx, cy);
        //block.popping = true;
        //block.pop_timer = pop_info.start_delay;

        // Add to global pop list
        //ds_list_add(player.pop_list, pop_info);
        //destroy_block(obj_game_control, cx, cy);
        total_blocks_destroyed++;
    }

    return total_blocks_destroyed;
}


