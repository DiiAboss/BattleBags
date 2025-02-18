/// @description
/// 


player_input[0].Update(self, x, y);
for (var p = 1; p < max_players; p++) {
    player_input[p].Update(self, x, y);
}

for (var i = 0; i < ds_list_size(global.player_list); i++) {
    var player = ds_list_find_value(global.player_list, i);
    player.input.Update(self, x, y);
}



//----------------------------------------------------------
// Multiplayer Lobby Code.
//----------------------------------------------------------
if (room == rm_local_multiplayer_lobby)
{
    if (delay > 0) {
        delay--;
    } else {
        var gp_num = gamepad_get_device_count();
        //if (xInput) gp_num = 12;
        
        if (player_assigning <= 0) {
            // ✅ Assign Player 1 (Keyboard/Mouse)
            if (keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left)) {
                player_input[0].InputType = INPUT.KEYBOARD;
                player.input.InputType = INPUT.KEYBOARD;
                player_assigning = 1;
                delay = max_delay;
                mouse_assigned = true;
                return;
            }
    
            // ✅ Assign Player 1 (Gamepad)
            for (var i = 0; i < gp_num; i++) {
                if (gamepad_is_connected(i) && gamepad_button_check(i, gp_start)) {
                    player_input[0].Device = i;
                    player_input[0].InputType = INPUT.GAMEPAD;
                    player.input.InputType = INPUT.GAMEPAD
                    player.input.Device = i;
                    player_assigning = 1;
                    delay = max_delay;
                    return;
                }
            }
        }
    
        // ✅ Assign Players 2, 3, and 4
        if (player_assigning >= 1 && player_assigning < max_players) {
            var assigned_player = player_assigning;
    
            // 🔹 If Player 1 is using Keyboard, assign others only Gamepads
            if (player_input[0].InputType == INPUT.KEYBOARD) {
                for (var i = 0; i < gp_num; i++) {
                    if (gamepad_is_connected(i) && gamepad_button_check(i, gp_start)) {
                        var already_used = false;
    
                        // ✅ Check if this gamepad is already assigned
                        for (var j = 0; j < assigned_player; j++) {
                            if (player_input[j].Device == i) {
                                already_used = true;
                                break;
                            }
                        }
    
                        if (!already_used) {
                            player_input[assigned_player].Device = i;
                            player_input[assigned_player].InputType = INPUT.GAMEPAD;
                            player.input.InputType = INPUT.GAMEPAD;
                            player.input.Device = i;
                            player_assigning++;
                            delay = max_delay;
                            return;
                        }
                    }
                }
            }
    
            // 🔹 If Player 1 is using Gamepad, allow Keyboard assignment for the next player
            if (player_input[0].InputType == INPUT.GAMEPAD) {
                if !(mouse_assigned) && (keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left))  {
                    player_input[assigned_player].InputType = INPUT.KEYBOARD;
                    player.input.InputType = INPUT.KEYBOARD;
                    player_assigning++;
                    delay = max_delay;
                    mouse_assigned = true;
                    return;
                }
    
                // 🔹 Assign additional Gamepads
                for (var i = 0; i < gp_num; i++) {
                    if (gamepad_is_connected(i) && gamepad_button_check(i, gp_start)) {
                        var already_used = false;
    
                        // ✅ Check if this gamepad is already assigned
                        for (var j = 0; j < assigned_player; j++) {
                            if (player_input[j].Device == i) || (player_input[j].Device == i - 4){
                                already_used = true;
                                break;
                            }
                        }
    
                        if (!already_used) {
                            player_input[assigned_player].Device = i;
                            player_input[assigned_player].InputType = INPUT.GAMEPAD;
                            player.input.InputType = INPUT.GAMEPAD;
                            player.input.Device = i;
                            player_assigning++;
                            delay = max_delay;
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // ✅ Reset assignment if a gamepad disconnects
    for (var p = 0; p < max_players; p++) {
        if (player_input[p].InputType == INPUT.GAMEPAD && !gamepad_is_connected(player_input[p].Device)) {
            player_assigning = p;
        }
    }
    
    if (player_assigning > 1)
    {
        for (var i = 0; i < max_players; i++)
        {
            if (player_input[i].SpeedUpKey)
            {
                room_goto(rm_local_multiplayer_game);
            }
        }
    }
}


if (room == rm_local_multiplayer_game)
{
    
    for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
        
        var next_y_pos = player.global_y_offset - player.shift_speed;
        
        if ((next_y_pos) <= -gem_size)
        {
            var remainder = next_y_pos - -(gem_size);
            random_set_seed(player.random_seed); // THIS ENSURE ALL PLAYERS GRIDS ARE ON THE SAME SEED
            shift_up_mp(player); // Shift the board up one position
            player.hovered_block[1]-=1;
            player.global_y_offset = remainder; // set the new offset to 0, to start the push up animation.
            player.random_seed ++; // THIS ENSURE ALL PLAYERS GRIDS ARE ON THE SAME SEED
        }
        else {
            player.global_y_offset -= player.shift_speed;
        }
        
        
        
        // ✅ Only find new matches if no pops are pending
        if (ds_list_size(player.pop_list) == 0) {
            find_and_destroy_matches_mp(self, player);
        }
        
        drop_blocks_mp(self, player);
    }
    
    
    
    
    
        for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
        
        if (player.input_type == INPUT.KEYBOARD)
        {
            player.pointer_x = mouse_x;
            player.pointer_y = mouse_y;
            
            block_dragged_mp(self, player);
        }
        else {
            var max_input_delay = 8;
            block_legacy_swap(self, player);
            
            if (player.input_delay > 0)
            {
                player.input_delay --;
                continue;
            }
            else {
                if (player.input.Up)
                {
                    if (player.hovered_block[1] > top_playable_row)
                    {
                        player.hovered_block[1] -= 1;
                    }
                    player.input_delay = max_input_delay;
                }
                
                if (player.input.Down)
                {
                    if (player.hovered_block[1] < bottom_playable_row)
                    {
                    player.hovered_block[1] += 1; 
                    }
                    player.input_delay = max_input_delay;
                }
                if (player.input.Left)
                {
                    if (player.hovered_block[0] > 0)
                        {
                            player.hovered_block[0] -= 1;
                        }
                        else {
                            player.hovered_block[0] = width - 2;
                        }
                    player.input_delay = max_input_delay;
                }
                
                if (player.input.Right)
                {
                    if (player.hovered_block[0] < width - 2)
                        {
                        player.hovered_block[0] += 1; 
                        }
                        else {
                            player.hovered_block[0] = 0;
                        }
                    player.input_delay = max_input_delay;
                }
            }
        }
    }
    
    //------------------------------------------------------------
    // DESTROY THE BLOCKS IN THE POP QUEUE
    //------------------------------------------------------------
    for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
       
        process_swap_mp(player);
        
        for (var _i = 0; _i < ds_list_size(player.pop_list); _i++) {

            var pop_data = ds_list_find_value(player.pop_list, _i);
                
            // Wait for start_delay
            if (pop_data.timer < pop_data.start_delay) {
                pop_data.timer++;
        
                var _x = pop_data.x;
                var _y = pop_data.y;
            } else {
                // Grow effect
                pop_data.scale += 0.05;
                
                    
                    
                // Once scale >= 1.1, pop is done
                if (pop_data.scale >= 1.1) {
                    var _x = pop_data.x;
                    var _y = pop_data.y;
        
                    // ✅ Store Gem Object Before Destroying
                    if (player.grid[_x, _y] != -1)
                    {
                        
                        var gem = player.grid[_x, _y];
                    }
                    else
                    {
                        break;
                    }
        
                        destroy_block(player, _x, _y);
                            
                            
                        var _pitch = clamp(0.5 + (0.1 * player.combo), 0.5, 5);
                        var _gain = clamp(0.5 + (0.1 * player.combo), 0.5, 0.75);
                        audio_play_sound(snd_pop_test_1, 10, false, _gain, 0, _pitch);
                    
                    // Remove from pop_list
                    ds_list_delete(player.pop_list, _i);
                    continue;
                }
            }
            // Write back updated pop_data
            ds_list_replace(player.pop_list, _i, pop_data);
        }
    }
}
