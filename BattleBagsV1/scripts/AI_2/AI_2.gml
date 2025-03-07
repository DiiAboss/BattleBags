/// @description AI Lobby Implementation with Self Parameter
/// Code to add to obj_local_multiplayer_control to support AI player selection


// Add to Step Event within rm_local_multiplayer_lobby section
function ai_lobby_update(_self) {
    // Check for AI button clicks
    if (mouse_check_button_pressed(mb_left)) {
        for (var i = 0; i < _self.max_players; i++) {
            var player = ds_list_find_value(global.player_list, i);
            
            // Only allow adding AI to slots that aren't already assigned
            if (player.input.InputType == INPUT.NONE && _self.player_assigning <= i) {
                var col_width = room_width / _self.max_players;
                var col_x = i * col_width;
                var col_y = room_height * 0.2 + 100;  // Position below player info
                
                // Check if AI button is clicked
                if (point_in_rectangle(mouse_x, mouse_y, 
                                    col_x + (col_width/2) - (_self.ai_button_width/2), 
                                    col_y, 
                                    col_x + (col_width/2) + (_self.ai_button_width/2), 
                                    col_y + _self.ai_button_height)) {
                    
                    // Toggle AI for this player slot
                    _self.ai_players_enabled[i] = !_self.ai_players_enabled[i];
                    
                    if (_self.ai_players_enabled[i]) {
                        // Set up as AI player
                        var ai_player = create_ai_player(i);
                        ai_player.ai_controller.set_difficulty(_self.ai_difficulty);
                        ds_list_replace(global.player_list, i, ai_player);
                        
                        // Mark this slot as assigned for progression purposes
                        if (_self.player_assigning == i) {
                            _self.player_assigning++;
                        }
                    } else {
                        // Revert to normal unassigned player
                        var normal_player = create_player(i);
                        ds_list_replace(global.player_list, i, normal_player);
                    }
                }
                
                // If AI is enabled, add difficulty buttons
                if (_self.ai_players_enabled[i]) {
                    for (var diff = 1; diff <= 5; diff++) {
                        var diff_x = col_x + (col_width/2) - 100 + (diff * 30);
                        var diff_y = col_y + _self.ai_button_height + 10;
                        var diff_radius = 12;
                        
                        if (point_in_distance(mouse_x, mouse_y, diff_x, diff_y, diff_radius)) {
                            var ai_player = ds_list_find_value(global.player_list, i);
                            ai_player.ai_controller.set_difficulty(diff);
                        }
                    }
                }
            }
        }
    }
}

// Add to Draw Event within rm_local_multiplayer_lobby section
function ai_lobby_draw(_self) {
    for (var i = 0; i < _self.max_players; i++) {
        var player = ds_list_find_value(global.player_list, i);
        var col_width = room_width / _self.max_players;
        var col_x = i * col_width;
        var col_y = room_height * 0.2 + 100;  // Position below player info
        
        // Only show AI buttons for slots that aren't already assigned to humans
        if ((player.input.InputType == INPUT.NONE || player.input.InputType == INPUT.AI) && 
            _self.player_assigning <= i) {
            
            // Draw AI toggle button
            draw_set_color(_self.ai_players_enabled[i] ? c_green : c_gray);
            draw_rectangle(col_x + (col_width/2) - (_self.ai_button_width/2), 
                        col_y, 
                        col_x + (col_width/2) + (_self.ai_button_width/2), 
                        col_y + _self.ai_button_height, 
                        false);
            draw_set_color(c_black);
            draw_rectangle(col_x + (col_width/2) - (_self.ai_button_width/2), 
                        col_y, 
                        col_x + (col_width/2) + (_self.ai_button_width/2), 
                        col_y + _self.ai_button_height, 
                        true);
            
            draw_set_color(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(col_x + (col_width/2), col_y + (_self.ai_button_height/2), 
                    _self.ai_players_enabled[i] ? "AI Player ON" : "Add AI Player");
            
            // If AI is enabled, show difficulty options
            if (_self.ai_players_enabled[i]) {
                var ai_player = ds_list_find_value(global.player_list, i);
                var current_diff = ai_player.ai_difficulty;
                
                draw_text(col_x + (col_width/2), col_y + _self.ai_button_height + 30, "Difficulty:");
                
                for (var diff = 1; diff <= 5; diff++) {
                    var diff_x = col_x + (col_width/2) - 100 + (diff * 30);
                    var diff_y = col_y + _self.ai_button_height + 50;
                    var diff_radius = 12;
                    
                    // Draw difficulty indicator
                    draw_set_color(diff == current_diff ? c_yellow : c_gray);
                    draw_circle(diff_x, diff_y, diff_radius, false);
                    draw_set_color(c_black);
                    draw_circle(diff_x, diff_y, diff_radius, true);
                    
                    // Draw difficulty label
                    draw_set_color(c_white);
                    draw_text(diff_x, diff_y + diff_radius + 10, _self.ai_difficulty_names[diff-1]);
                }
                
                draw_text(col_x + (col_width/2), col_y + _self.ai_button_height + 80, 
                        "AI Type: " + _self.ai_difficulty_names[current_diff-1]);
            }
        }
    }
    
    // Reset drawing properties
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// Helper function for circular button detection
function point_in_distance(px, py, cx, cy, radius) {
    var dist = point_distance(px, py, cx, cy);
    return (dist <= radius);
}





/// @function setup_ai_players_from_lobby
/// @description Set up AI players for the multiplayer game
/// @param {id} _self The multiplayer controller object
function setup_ai_players_from_lobby(_self) {
    // This function should only run once when entering the game room
    static setup_done = false;
    if (setup_done) return;
    setup_done = true;
    
    // Make sure all AI players have the necessary properties
    for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
        
        if (player.is_ai) {
            // Double check that AI players have all required properties
            if (player.pop_list == undefined) {
                player.pop_list = ds_list_create();
            }
            
            if (player.swap_info == undefined) {
                player.swap_info = create_swap_info();
            }
            
            if (player.swap_queue == undefined) {
                player.swap_queue = create_swap_queue();
            }
            
            // Setup display position
            var draw_x_start = room_width / (_self.max_players + 1) - (_self.width * 0.5);
            player.board_x_offset = 96 + ((draw_x_start) * i) + (i * (9 * _self.gem_size));
            
            // Make sure the AI player's grid is properly initialized
            random_set_seed(_self.random_seed + i);
            if (!is_array(player.grid) || array_length(player.grid) < 1) {
                player.grid = create_grid_array();
                spawn_random_blocks_in_array(player.grid, player.start_row);
            }
            
            player.random_seed = _self.random_seed;
            player.shift_speed = _self.shift_speed;
            player.default_shift_speed = _self.shift_speed;
            player.alive = true;
        }
    }
}
