/// @description Initialize block stack
// Basic properties
sprite_index = noone;
image_speed = 0;
depth = 15;

// Stack configuration
max_width = 5;
max_height = 4;
block_size = 32;
horizontal_spacing = 32;
vertical_spacing = 24;
targetter = noone;

// Block tracking
blocks = ds_grid_create(max_width, max_height);
block_count = 0;

// Populate stack with a pyramid structure
// We'll fill blocks from bottom to top
for (var _y = max_height - 1; _y >= 0; _y--) {
    // Calculate width for this row (wider at bottom, narrower at top)
    var row_width = min(max_width, max_height - _y);
    
    // Center the blocks in each row
    var start_x = floor((max_width - row_width) / 2);
    
    for (var _x = 0; _x < max_width; _x++) {
        // Only create blocks within the row's width
        if (_x >= start_x && _x < start_x + row_width) {
            // Choose a random block type
            var block_type = choose(
                BLOCK.RED, 
                BLOCK.YELLOW, 
                BLOCK.GREEN, 
                BLOCK.PINK, 
                BLOCK.PURPLE,
                BLOCK.LIGHTBLUE,
                BLOCK.ORANGE,
                BLOCK.BLUE
            );
            
            // Add block to the grid
            blocks[# _x, _y] = block_type;
            block_count++;
        } else {
            // Empty space in the grid
            blocks[# _x, _y] = BLOCK.NONE;
        }
    }
}

// Visual properties
float_offset = 0;
float_speed = 0.02;
float_range = 2;
sparkle_timer = 0;
sparkle_interval = 20;

// Interface function for drones to get a block
get_block_type = function() {
    if (block_count > 0) {
        // Find the topmost block in the stack
        var removed_block = BLOCK.NONE;
        
        // Start from the top and work down
        for (var _y = 0; _y < max_height; _y++) {
            for (var _x = 0; _x < max_width; _x++) {
                // If we find a block, remove it and return its type
                if (blocks[# _x, _y] != BLOCK.NONE) {
                    removed_block = blocks[# _x, _y];
                    blocks[# _x, _y] = BLOCK.NONE;  // Remove block from stack
                    block_count--;
                    
                    // Create removal effect
                    var block_x = _x * horizontal_spacing + x_offset_for_row(_y);
                    var block_y = _y * vertical_spacing;
                    effect_create_above(ef_spark, x + block_x, y - block_y, 0, c_white);
                    
                    // If stack is empty, destroy or reset
                    if (block_count <= 0) {
                        // Either destroy the stack
                        // instance_destroy();
                        
                        // Or reset after a delay (handled in Step event)
                        alarm[0] = room_speed * 10; // Reset in 10 seconds
                    }
                    
                    // Release this stack for other drones
                    targetter = noone;
                    
                    // Return the block type
                    return removed_block;
                }
            }
        }
    }
    
    // No blocks available
    return -1;
}

// Helper to calculate x offset for each row to center blocks
function x_offset_for_row(_row) {
    var row_width = min(max_width, max_height - _row);
    return (max_width - row_width) * horizontal_spacing / 2;
}