
/// @description Draw Conveyor Belt with enhanced visuals

// Draw conveyor background
draw_set_alpha(0.7);
draw_rectangle_color(
    x - conveyor_width/2, conveyor_activation_y,
    x + conveyor_width/2, conveyor_start_y,
    c_navy, c_navy, c_black, c_black, false
);
draw_set_alpha(1.0);

// Draw conveyor belt lines (scrolling animation)
var belt_segments = 20;
var segment_height = (conveyor_start_y - conveyor_activation_y) / belt_segments;

for (var i = 0; i <= belt_segments; i++) {
    var y_pos = conveyor_activation_y + (i * segment_height) + belt_animation_offset;
    if (y_pos > conveyor_start_y) y_pos -= segment_height;
    
    var line_alpha = 0.5 + (0.5 * (i mod 2)); // Alternate opacity for visual interest
    
    draw_set_alpha(line_alpha);
    draw_line_width_color(
        x - conveyor_width/2, y_pos,
        x + conveyor_width/2, y_pos,
        1, c_gray, c_gray
    );
}
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

// Draw all blocks on the conveyor
for (var i = 0; i < ds_list_size(conveyor_blocks); i++) {
    var block_data = conveyor_blocks[| i];
    
    // Calculate lane position
    var lane_width = conveyor_width / lane_count;
    var lane_x = x - conveyor_width/2 + (block_data.lane * lane_width) + (lane_width/2);
    
    // Get the block type
    var block_type = variable_struct_exists(block_data, "block_type") ? 
                block_data.block_type : BLOCK.RANDOM;
    
    // Get the appropriate sprite
    var block_sprite = block_sprites[? block_type];
    if (block_sprite == undefined) {
        block_sprite = sprite_for_block(BLOCK.RANDOM);
    }
    
    // Draw the block
    draw_sprite(block_sprite, 0, lane_x, block_data.y_pos);
    
    // Draw special effects for special blocks
    if (variable_struct_exists(block_data, "is_special") && block_data.is_special) {
        draw_set_alpha(pulsing_alpha);
        draw_circle_color(
            lane_x, block_data.y_pos,
            16, c_white, c_yellow, false
        );
        draw_set_alpha(1.0);
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
