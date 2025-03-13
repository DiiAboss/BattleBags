
/// @description Draw Conveyor Belt with enhanced visuals

// Draw conveyor background
draw_set_alpha(0.7);
draw_rectangle_color(
    x - conveyor_width/2, conveyor_activation_y,
    x + conveyor_width/2, conveyor_start_y,
    c_navy, c_navy, c_black, c_black, false
);
draw_set_alpha(1.0);

// Draw lane separators
if (show_grid_overlay) {
    var lane_width = conveyor_width / lane_count;
    for (var i = 0; i <= lane_count; i++) {
        var lane_x = x - conveyor_width/2 + (i * lane_width);
        
        // Highlight unlocked lanes
        var line_color = (i <= lanes_unlocked) ? c_white : c_dkgray;
        
        draw_line_width_color(
            lane_x, conveyor_activation_y,
            lane_x, conveyor_start_y,
            1, line_color, line_color
        );
    }
}

// Draw activation line with animated effect
var time_offset = (current_time / 300) mod 360;
var line_width = 3 + sin(degtorad(time_offset)) * 1.5; // Pulsing effect

draw_line_width_color(
    x - conveyor_width/2, conveyor_activation_y,
    x + conveyor_width/2, conveyor_activation_y,
    line_width, c_red, c_red
);

// Draw activation zone highlight
draw_set_alpha(pulsing_alpha);
draw_rectangle_color(
    x - conveyor_width/2, conveyor_activation_y - 15,
    x + conveyor_width/2, conveyor_activation_y + 5,
    c_red, c_red, c_red, c_red, false
);
draw_set_alpha(1.0);

// Step 1: Find unique y-positions and store indices of blocks sharing them
var y_positions = [];  // Stores unique y-positions
var grouped_blocks = [];  // Stores block indices per y-position

for (var i = 0; i < ds_list_size(conveyor_blocks); i++) {
    var block_data = conveyor_blocks[| i];
    var y_value = block_data.y_pos;
    
    // Check if y_position exists
    var found_index = -1;
    for (var j = 0; j < array_length(y_positions); j++) {
        if (y_positions[j] == y_value) {
            found_index = j;
            break;
        }
    }
    
    // If new y_position, add it and create an array for blocks at this height
    if (found_index == -1) {
        array_push(y_positions, y_value);
        array_push(grouped_blocks, [i]); // Create new array with this block index
    } else {
        array_push(grouped_blocks[found_index], i); // Add to existing y-position group
    }
}

// Step 2: Draw the blocks, adjusting only those at the same y-position
for (var k = 0; k < array_length(y_positions); k++) {
    var block_list = grouped_blocks[k];  // Blocks sharing this y-position
    var block_count = array_length(block_list);
    
    // Calculate spacing based on count
    var max_block_width = conveyor_width * 0.9;  
    var block_spacing = max_block_width / block_count;
    var block_size = clamp(block_spacing * 0.8, 16, 64);  
    var start_x = x - (block_spacing * (block_count - 1)) * 0.5;  
    
    // Draw each block at the computed X position
    for (var j = 0; j < block_count; j++) {
        var index = block_list[j];
        var block_data = conveyor_blocks[| index];

        var block_type = variable_struct_exists(block_data, "block_type") ? block_data.block_type : BLOCK.RANDOM;
        var block_sprite = block_sprites[? block_type];

        if (block_sprite == undefined) {
            block_sprite = sprite_for_block(BLOCK.RANDOM);
        }

        var block_x = start_x + (j * block_spacing); // Position block correctly
        
        draw_sprite_ext(block_sprite, 0, block_x, block_data.y_pos, 
            block_size / 64, block_size / 64, 0, c_white, 1);
    }
}

// Draw stats if debug mode is on
if (keyboard_check(vk_tab)) {
    draw_set_color(c_white);
    draw_text(x + conveyor_width/2 + 10, conveyor_activation_y, 
            "Blocks in queue: " + string(ds_list_size(conveyor_blocks)));
    draw_text(x + conveyor_width/2 + 10, conveyor_activation_y + 20, 
            "Blocks processed: " + string(blocks_processed));
    draw_text(x + conveyor_width/2 + 10, conveyor_activation_y + 40, 
            "Special blocks: " + string(special_blocks_processed));
}
