/// @description SCAN THE BOARD FOR CERTAIN BLOCKS

if (game_over_state)
{
    alarm[0] = scan_board;
    return;
}

// TODO: FIX BIG BLOCK SPAWNS ITS COLOR ON BOTTOM ROW

var number_per_big_block = 2;

//SCAN TOP TO BOTTOM

// Scan the board for big blocks
var big_blocks = []; // Proper empty array
big_block_types_on_grid = []; // Ensure this is cleared at each scan

for (var _y = 0; _y < bottom_playable_row; _y++) {
    for (var _x = 0; _x < board_width; _x++) {
        var block = grid[_x, _y];
        var is_parent = block.big_parent[0] == _x && block.big_parent[1] == _y;
        if (block.type != BLOCK.NONE && block.type != BLOCK.MEGA && block.is_big && is_parent) {
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
    
    for (var _n = 0; _n < number_per_big_block; _n++)
    {
        var temp = [];
        for (var _block = 0; _block < board_width - 1; _block++)
        {
            var target_block_type = grid[_block, bottom_playable_row].type;
            
            if target_block_type!= block_type
            {
                array_push(temp, _block);
            }
        }
        
        var _rand = irandom(array_length(temp) - 1);
        grid[_rand, bottom_playable_row].type = block_type;
    }
    
    
}


// Reset the alarm
//alarm[0] = room_speed; // Runs every 30 frames assuming 30 FPS

alarm[0] = scan_board;

