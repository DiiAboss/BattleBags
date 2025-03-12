/// @description Draw the block stack

// Draw base platform
draw_sprite(sprite_index, image_index, x, y);

// Draw all blocks in the stack
for (var _y = max_height - 1; _y >= 0; _y--) {
    // Calculate vertical position with floating effect
    var draw_y_base = _y - vertical_spacing;
    
    if (_y == 0) {
        // Add float effect only to the top layer
        draw_y_base -= float_offset;
    }
    
    for (var _x = 0; _x < max_width; _x++) {
        var block_type = blocks[# _x, _y];
        
        if (block_type != BLOCK.NONE) {
            // Calculate position for this block
            var draw_x = x + _x * horizontal_spacing + x_offset_for_row(_y);
            var draw_y = y - _y * vertical_spacing;
            
            // Draw the block
            var block_sprite = sprite_for_block(block_type);
            draw_sprite(block_sprite, 0, draw_x, draw_y);
            
            // Draw highlight on top blocks
            if (is_top_block(_x, _y)) {
                draw_sprite_ext(
                    spr_block_highlight, 0,
                    draw_x, draw_y,
                    1, 1, 0, c_white, 0.3 + sin(current_time * 0.005) * 0.2
                );
            }
        }
    }
}

// Helper function to check if a block is on top (no block above it)
function is_top_block(_x_pos, _y_pos) {
    // If we're already at the top row, it's a top block
    if (_y_pos == 0) return true;
    
    // Check if there's any block above this one
    for (var _y = 0; _y < _y_pos; _y++) {
        // Blocks typically stack in a pyramid, so check columns
        // Simplified check - just check directly above
        if (blocks[# _x_pos, _y] != BLOCK.NONE) {
            return false;
        }
    }
    
    return true;
}
