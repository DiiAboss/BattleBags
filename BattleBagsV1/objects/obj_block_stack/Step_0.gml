/// @description Update block stack

// Visual effects for active stack
if (block_count > 0) {
    // Floating animation for blocks
    float_offset = sin(current_time * float_speed) * float_range;
    
    // Occasional sparkles on top blocks
    sparkle_timer++;
    if (sparkle_timer >= sparkle_interval) {
        sparkle_timer = 0;
        
        // Find the topmost block and create sparkles
        for (var _y = 0; _y < max_height; _y++) {
            var found_block = false;
            
            for (var _x = 0; _x < max_width; _x++) {
                if (blocks[# _x, _y] != BLOCK.NONE) {
                    // Calculate position for this block
                    var block_x = _x * horizontal_spacing + x_offset_for_row(_y) + x;
                    var block_y = _y * vertical_spacing - float_offset;
                    
                    // Create sparkle effect
                    //effect_create_above(ef_star, block_x, block_y, 0, c_white);
                    found_block = true;
                    break;
                }
            }
            
            if (found_block) break;
        }
    }
}
