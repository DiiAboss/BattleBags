/// @description SCAN THE BOARD FOR CERTAIN BLOCKS

// Reset all spawn weights to default (12)
for (var _c = 0; _c < numberOfGemTypes; _c++) {
    global.color_spawn_weight[_c] = 12;
}
// Scan the board for big blocks
var big_blocks = []; // Proper empty array
big_block_types_on_grid = []; // Ensure this is cleared at each scan

for (var _y = 0; _y < bottom_playable_row; _y++) {
    for (var _x = 0; _x < board_width; _x++) {
        var block = grid[_x, _y];
        
        if (block.type != BLOCK.NONE && block.is_big) {
            // Add to big_blocks array if it's not already in there
            if (!array_contains(big_blocks, block.group_id)) {
                array_push(big_blocks, block.group_id);
                array_push(big_block_types_on_grid, block.type);
            }
        }
    }
}

// Apply bonuses based on detected big blocks
for (var i = 0; i < array_length(big_block_types_on_grid); i++) {
    var block_type = big_block_types_on_grid[i];
    global.color_spawn_weight[block_type] += 25; // Increase spawn weight
}


// Reset the alarm
//alarm[0] = room_speed; // Runs every 30 frames assuming 30 FPS






alarm[0] = scan_board;

