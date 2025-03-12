draw_sprite_ext(sprite_for_block(current_block_type), 0, x, y, 0.5, 0.5, 0, c_white, 1);

// If we have stacked blocks, draw them in pyramid form
if (variable_instance_exists(id, "stacked_blocks") && ds_list_size(stacked_blocks) > 0) {
    // Draw all blocks in the pyramid
    for (var yy = max_height - 1; yy >= 0; yy--) {
        // Calculate vertical position with floating effect
        var draw_y_base = y - yy * vertical_spacing;
        
        if (yy == 0) {
            // Add float effect only to the top layer
            draw_y_base -= float_offset;
        }
        
        for (var xx = 0; xx < max_width; xx++) {
            var block_type = current_block_type;
            
            if (block_type != -1) {
                // Calculate position for this block
                var draw_x = x + xx * horizontal_spacing + x_offset_for_row(yy);
                var draw_y = draw_y_base;
                
                // Draw the block (use sprite based on block type)
                var block_sprite = sprite_for_block(current_block_type);
                draw_sprite_ext(block_sprite, 0, draw_x, draw_y, 0.5, 0.5, 0, c_white, 1);
                
                // Draw highlight on top blocks
                if (is_top_block(xx, yy)) {
                    draw_sprite_ext(
                        block_sprite, 1,
                        draw_x, draw_y,
                        0.6, 0.6, 0, c_white, 0.3 + sin(current_time * 0.005) * 0.2
                    );
                }
            }
        }
    }
}


// Draw debug info
if (keyboard_check(vk_tab)) {
    draw_set_color(c_white);
    draw_text(x - 40, y + 20, state);
    draw_text(x - 40, y + 35, "Type: " + string(current_block_type));
}