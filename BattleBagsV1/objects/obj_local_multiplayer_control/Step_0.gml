/// @description
/// 


player_input[0].Update(self, x, y);
for (var p = 1; p < max_players; p++) {
    player_input[p].Update(self, x, y);
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
    
    
    for (var i = 0; i < max_players; i++)
    {
        global_y_offsets[i] -= shift_speeds[i];
        
    if (global_y_offsets[i] <= -64) {
        global_y_offsets[i] = 0;
        //last_position[1] -= 1;
        shift_up_mp(player_grid[i]);
    }
        
    }
    
    
    
}
