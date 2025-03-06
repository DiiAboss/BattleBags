function process_popping(player) {
    for (var i = 0; i < ds_list_size(player.pop_list); i++) {
        var pop_data = ds_list_find_value(player.pop_list, i);

        // ✅ Wait for start_delay
        if (pop_data.timer < pop_data.start_delay) {
            pop_data.timer++;
        } else {
            pop_data.scale += 0.05;

            if (pop_data.scale >= 1.1) {
                var _x = pop_data.x;
                var _y = pop_data.y;

                if (player.grid[_x, _y] != BLOCK.NONE) {
                    destroy_block(player, _x, _y);
                    player.grid[_x, _y].popping = false;
                    player.grid[_x, _y - 1].falling = true; 
                    player.grid[_x, _y - 1].fall_delay = 10;
                    
                    if player.grid[_x, _y - 1] != BLOCK.NONE
                    {
                    player.grid[_x, _y - 1].falling = true; 
                        player.grid[_x, _y - 1].fall_delay = 10;
                        player.grid[_x, _y - 1].popping = false;
                    }
                    
                }

                var _pitch = clamp(0.5 + (0.1 * player.combo), 0.5, 5);
                var _gain = clamp(0.5 + (0.1 * player.combo), 0.5, 0.75);
                audio_play_sound(snd_pop_test_1, 10, false, _gain, 0, _pitch);

                // ✅ Remove from pop_list
                ds_list_delete(player.pop_list, i);
                i--; // Adjust index after deletion
            }
        }
        ds_list_replace(player.pop_list, i, pop_data);
    }
}