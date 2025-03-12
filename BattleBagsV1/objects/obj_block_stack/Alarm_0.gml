/// @description Reset stack after delay

// Repopulate the stack
block_count = 0;

// Fill from bottom to top again
for (var _y = max_height - 1; _y >= 0; _y--) {
    var row_width = min(max_width, max_height - _y);
    var start_x = floor((max_width - row_width) / 2);
    
    for (var _x = 0; _x < max_width; _x++) {
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
            blocks[# _x, _y] = BLOCK.NONE;
        }
    }
}

// Create reset effect
effect_create_above(ef_ring, x, y - vertical_spacing * 2, 1, c_white);
