/// @description Insert description here
// You can write your code in this editor


var player = noone;
for (var i = 0; i < total_enemies; i++)
{
    player = enemy_list[i];
}

if (!player || player == noone) return;
    

if (player.is_ai)
{
    if (!player.ai_scanner.leveling_mode) player.ai_scanner.leveling_mode = true;
    else player.ai_scanner.leveling_mode = false;
}

    
    setup_ai_players_from_lobby(self);
    update_ai_players(self);
    
            
        if (player.combo > 0 || !ds_list_empty(player.pop_list))
        {
            player.combo_timer += 1;
            player.shift_speed = 0.5 * player.default_shift_speed;
        }
        else {
            player.shift_speed = player.default_shift_speed;
        }
        
        if (player.combo_timer == player.max_combo_timer)
        {
            player.combo = 0;
            player.combo_timer = player.max_combo_timer;   
        }
        
        
        update_topmost_row_mp(player);
        
        // Drop the blocks
        drop_blocks_mp(self, player);
        
        // Destroy the blocks in the pop queue
        if (ds_list_size(player.pop_list) > 0) {
            pop_blocks_in_pop_queue(self, player);
        }
        
        var next_y_pos = player.global_y_offset - player.shift_speed;
        
        if ((next_y_pos) <= -gem_size)
        {
            var remainder = next_y_pos - -(gem_size);
            random_set_seed(player.random_seed); // THIS ENSURE ALL PLAYERS GRIDS ARE ON THE SAME SEED
            shift_up_mp(player); // Shift the board up one position
            player.hovered_block[1] -= 1;
            player.global_y_offset = remainder; // set the new offset to 0, to start the push up animation.
            player.random_seed ++; // THIS ENSURE ALL PLAYERS GRIDS ARE ON THE SAME SEED
        }
        else {
            player.global_y_offset -= player.shift_speed;
        }
        darken_bottom_row(player);
        // Swap the blocks
        process_swap_mp(player);
        
        // Find any matches on the board and add them to the pop queue
        find_matches_and_add_to_pop_list(self, player);
    }


        var max_input_delay = 8;
        block_legacy_swap(self, player);
        
        if (player.input_delay > 0)
        {
            player.input_delay --;
        }
        else {
            
            if (player.input.Up)
            {
                if (player.hovered_block[1] > top_playable_row)
                {
                    player.hovered_block[1] -= 1;
                }
                if !(player.is_ai) player.input_delay = max_input_delay;
                    else player.input_delay = 1;
                
            }
            
            if (player.input.Down)
            {
                if (player.hovered_block[1] < bottom_playable_row)
                {
                player.hovered_block[1] += 1; 
                }
                if !(player.is_ai) player.input_delay = max_input_delay;
                    else player.input_delay = 1;
            }
            
            if (player.input.Left)
            {
                if (player.hovered_block[0] > 0)
                    {
                        player.hovered_block[0] -= 1;
                    }
                    else {
                        player.hovered_block[0] = width - 1;
                    }
                if !(player.is_ai) player.input_delay = max_input_delay;
                    else player.input_delay = 1;
            }
            
            if (player.input.Right)
            {
                if (player.hovered_block[0] < width - 1)
                {
                player.hovered_block[0] += 1; 
                }
                else {
                    player.hovered_block[0] = 0;
                }
                if !(player.is_ai) player.input_delay = max_input_delay;
                    else player.input_delay = 1;
            }
        }




