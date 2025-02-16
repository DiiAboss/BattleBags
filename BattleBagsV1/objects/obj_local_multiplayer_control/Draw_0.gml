/// @description
/// 

if (room == rm_local_multiplayer_lobby)
{
    // ✅ Get screen dimensions
    var screen_width = room_width;
    var screen_height = room_height;
    
    // ✅ Define column layout
    var col_width = screen_width / max_players; // Each column is 1/4 of the screen
    var col_height = screen_height * 0.8; // Columns cover 80% of screen height
    
    // ✅ Header rectangle at 20% screen height
    var header_y = screen_height * 0.2;
    draw_set_color(c_black);
    draw_rectangle(0, header_y, screen_width, header_y + 60, false);
    draw_set_color(c_white);
    draw_text(screen_width / 2 - 100, header_y + 20, "Multiplayer Lobby");
    
    
    // ✅ Loop through each player slot
    for (var i = 0; i < max_players; i++) {
        var col_x = i * col_width;
        var col_y = screen_height - col_height; // Start from 80% of the screen height
        
        var col_x_text_offset = 960 / max_players;
    
        // ✅ Draw player slot background
        draw_set_color(c_dkgray);
        if (player_assigning == i) 
        {
            draw_rectangle(col_x-12, col_y-12, col_x + col_width, screen_height, false);
            draw_set_color(c_white);
            draw_rectangle(col_x - 12, col_y - 12, col_x + col_width, screen_height, true);
        }
        else 
        {
            draw_rectangle(col_x, col_y, col_x + col_width, screen_height, false);
            draw_set_color(c_white);
            draw_rectangle(col_x, col_y, col_x + col_width, screen_height, true);
            
        }
    
        // ✅ Display player number
        draw_text(col_x + col_x_text_offset, col_y + 20, "Player " + string(i + 1));
    
        // ✅ Check if player is assigned a control method
        if (player_input[i].InputType == INPUT.KEYBOARD) {
            draw_set_color(c_white);
            draw_text(col_x + col_x_text_offset, col_y + 50, "Input: MOUSE & KEYBOARD");
        } 
        else if (player_input[i].InputType == INPUT.GAMEPAD) {
            draw_set_color(c_blue);
            draw_text(col_x + col_x_text_offset, col_y + 50, "Input: GAMEPAD " + string(player_input[i].Device));
        } 
        else {
            // ✅ Display "Press Start" for unassigned players
            if player_assigning < i
            {
                draw_set_color(c_grey);
                draw_set_alpha(0.5);
            }
            else 
            {
                draw_set_color(c_red);
                draw_set_alpha(1);
            }
            
            if (player_assigning <= i) {
                if !(mouse_assigned)
                {
                    draw_text(col_x + col_x_text_offset, col_y + 50, "Press START or Left Click \n or Press Start on Gamepad");
                }
                else {
                    draw_text(col_x + col_x_text_offset, col_y + 50, "Press Start on Gamepad");
                }
                
            }
        }
        
        // ✅ Reset color after each player box
        draw_set_color(c_white);
        draw_set_alpha(1);
    }
}



if (room == rm_local_multiplayer_game)
{
    for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
        
        if (player.alive) {
            draw_player_grid(self, player);
        }
    }
}

