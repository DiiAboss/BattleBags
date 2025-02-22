function drop_blocks_mp(mp_control, player, fall_speed = 2) {
    var width = mp_control.width;
    var height = mp_control.height;
    var bottom_row = mp_control.bottom_playable_row;
    var has_fallen = false; // ✅ Track if any block has moved

    //  Process from **bottom-up** (ensures things fall properly)
    for (var j = bottom_row; j >= 0; j--) {
        for (var i = 0; i < width; i++) {
            var gem = player.grid[i, j];
            //process_mega_blocks(_self, i, j);
            if (gem.type != BLOCK.NONE) { // ✅ Only process valid blocks
                var below = player.grid[i, j + 1];
                
                // Frozen Blocks
                process_falling_frozen_blocks(gem);
                
                //  **Normal Single Block Falling**
                if (below.type == BLOCK.NONE) {
                    // ✅ Apply **fall delay**
                    if (gem.fall_delay < gem.max_fall_delay) {
                        gem.fall_delay++;
                        gem.falling = true;
                    }
                    else {
                        process_falling_slime_block(gem);
                        
                        player.grid[i, j + 1] = gem;
                        player.grid[i, j] = create_block(BLOCK.NONE);
                        gem.fall_delay = 0;
                    }
                }
                else
                {
                    gem.fall_delay = below.fall_delay;
                    gem.falling = below.falling;
                    gem.is_enemy_block = false;
                }
            }
        }
    }
}


function process_falling_frozen_blocks(gem)
{
    //  **Frozen blocks never fall**
    if (gem.frozen) {					
        gem.fall_delay = 0;
        gem.falling = false;
    }
}

function process_falling_slime_block(gem)
{
    // 🔹 **Slime Block Falling**
    if (gem.slime_hp > 0) { 
        // 🔥 **Reduce Slime HP when moving**
        gem.slime_hp -= 1;

        // ✅ **If slime HP runs out, return to normal**
        if (gem.slime_hp <= 0) {
            gem.max_fall_delay = 5;  // ✅ Normal falling speed
            gem.swap_speed = 0.15;    // ✅ Normal swap speed
        }
    }
}    
