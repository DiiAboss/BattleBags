/// @description


var player_one = ds_list_find_value(global.player_list, 0);

for (var i = 0; i < ds_list_size(global.player_list); i++) {
    var player = ds_list_find_value(global.player_list, i);
    player.input.Update(self, x, y);
}



//----------------------------------------------------------
// Multiplayer Lobby Code.
//----------------------------------------------------------
if (room == rm_local_multiplayer_lobby)
{
    ai_lobby_update(self);
    if (delay > 0) {
        delay--;
    } else {
        var gp_num = gamepad_get_device_count();
        var player = ds_list_find_value(global.player_list, player_assigning);
    
        // ✅ Assign Keyboard (only once)
        if (!mouse_assigned && (keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left))) {
            player.input.InputType = INPUT.KEYBOARD;
            player.input.Device = -player._id;
            player_assigning++;
            delay = max_delay;
            mouse_assigned = true;
            return;
        }
    
        // ✅ Assign Gamepads
        for (var i = 0; i < gp_num; i++) {
            if (gamepad_is_connected(i) && gamepad_button_check_pressed(i, gp_start)) {
                // Ensure gamepad isn't already taken
                var taken = false;
                for (var t = 0; t < array_length(gamepad_taken_list); t++) {
                    if (gamepad_taken_list[t] == i) {
                        taken = true;
                        break;
                    }
                }
    
                if (!taken) {
                    player.input.InputType = INPUT.GAMEPAD;
                    player.input.Device = i;
    
                    // Store device in gamepad_taken_list
                    for (var t = 0; t < array_length(gamepad_taken_list); t++) {
                        if (gamepad_taken_list[t] == -1) {
                            gamepad_taken_list[t] = i;
                            gamepad_taken_list[t + 4] = i + 4;
                            break;
                        }
                    }
    
                    player_assigning++;
                    delay = max_delay;
                    return;
                }
            }
        }
    
        // ✅ Reset assignment if a gamepad disconnects
        for (var p = 0; p < max_players; p++) {
            var _player = ds_list_find_value(global.player_list, p);
            if (_player.input.InputType == INPUT.GAMEPAD && !gamepad_is_connected(_player.input.Device)) {
                player_assigning = p; // Reset to reassign this player
    
                // Remove from gamepad_taken_list
                for (var t = 0; t < array_length(gamepad_taken_list); t++) {
                    if (gamepad_taken_list[t] == _player.input.Device) {
                        gamepad_taken_list[t + 4] = -1;
                        gamepad_taken_list[t] = -1;
                        break;
                    }
                }
    
                _player.input.InputType = INPUT.NONE;
                _player.input.Device = -1;
            }
        }
    
        // ✅ Proceed to Game
        if (player_assigning >= 1) {
            var player_one = ds_list_find_value(global.player_list, 0);
            if (player_one.input.SpeedUpKey) {
                for (var p = ds_list_size(global.player_list) - 1; p > 1; p--)
                {
                   player = ds_list_find_value(global.player_list, p);
                    if (player.input.InputType == INPUT.NONE)
                    {
                        ds_list_delete(global.player_list, p);
                    }
                }
                
                max_players = ds_list_size(global.player_list);
                room_goto(rm_local_multiplayer_game);
            }
        }
    }
}

if (room == rm_local_multiplayer_game)
{
    
    if (player.is_ai && player.input.ActionPress) {
        show_debug_message("AI trying to swap at position: " + 
                        string(player.hovered_block[0]) + "," + 
                        string(player.hovered_block[1]));
    }

    
    setup_ai_players_from_lobby(self);
    update_ai_players(self);
    for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
        
        update_topmost_row_mp(self, player);
        
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



    //test
    for (var i = 0; i < ds_list_size(global.player_list); i++) {
       var player = ds_list_find_value(global.player_list, i);
       if (player.input.InputType == INPUT.KEYBOARD)
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
                           player.hovered_block[0] = width - 1;
                       }
                   player.input_delay = max_input_delay;
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
                   player.input_delay = max_input_delay;
               }
           }
       }
   }
}

