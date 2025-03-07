/// @description

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
            draw_set_color(c_grey);
            draw_rectangle(col_x, col_y, col_x + col_width, screen_height, true);
            
        }
    
        // ✅ Display player number
        draw_text(col_x + col_x_text_offset, col_y + 20, "Player " + string(i + 1));
            var player = ds_list_find_value(global.player_list, i);
            
        // ✅ Check if player is assigned a control method
        if (player.input.InputType == INPUT.KEYBOARD) {
            draw_set_color(c_white);
            draw_text(col_x + col_x_text_offset, col_y + 50, "Input: MOUSE & KEYBOARD");
        } 
        else if (player.input.InputType == INPUT.GAMEPAD) {
            draw_set_color(c_blue);
            draw_text(col_x + col_x_text_offset, col_y + 50, "Input: GAMEPAD " + string(player.input.Device));
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
    
    ai_lobby_draw(self);
}



if (room == rm_local_multiplayer_game)
{
    
    
    for (var i = 0; i < ds_list_size(global.player_list); i++) {
        var player = ds_list_find_value(global.player_list, i);
        
        if (player.alive) {
            draw_player_grid(self, player);
        }
        
        draw_text(player.hovered_block[0], player.hovered_block[1], "Combo: " + string(player.combo))
        
        if (player.hovered_block[0] >= 0 && player.hovered_block[1] >= 0) {
            var hover_i = player.hovered_block[0];
            var hover_j = player.hovered_block[1];
            show_hovered_block_stats(player, hover_i, hover_j);
            
            if (hover_i >= 0 && hover_i < width && hover_j >= 0 && hover_j < height) {
                var hover_gem = player.grid[hover_i, hover_j];
                var rect_x1 = player.board_x_offset + (hover_i * gem_size);
                var rect_y1 = (hover_j * gem_size) + player.global_y_offset;
                var rect_x2 = rect_x1 + gem_size;
                var rect_y2 = rect_y1 + gem_size;
                var scale = 1.1 * (gem_size / 64);
                var offset_x = 48 * (gem_size / 64);
                var offset_y = 24 * (gem_size / 64);
                
                var offset = 32 * (gem_size / 64);
                if (player.swap_in_progress)
                {
                    scale = 1 * (gem_size / 64);
                }
                
                var color = c_white;
                
                if player.is_ai  && player.ai_scanner.leveling_mode
                {
                  color = c_red;   
                }
                
                if (player.input.InputType == INPUT.GAMEPAD || player.input.InputType == INPUT.AI) {
                        if (hover_i + 1 < width)
                        {
                            var hover_gem2 = player.grid[hover_i + 1, hover_j];
                            
                            
                            draw_sprite_ext(spr_gem_hovered_border, -1, rect_x2 - offset, rect_y2 - offset, scale, scale, 0, color, 1);
                            
                            if (hover_gem2.type != BLOCK.NONE)
                            {
                                draw_sprite_ext(sprite_for_block(hover_gem2.type), hover_gem2.img_number, rect_x2 + offset, rect_y2 - offset, scale, scale, 0, color, 1);
                                draw_sprite_ext(hover_gem2.powerup.sprite, 0, rect_x2 + offset_x, rect_y2 - offset, scale, scale, 0, color, 1);
                            }
                        }
                        
                        draw_sprite_ext(spr_gem_hovered_border, -1, rect_x2 + offset, rect_y2 - offset, scale, scale, 0, color, 1);
                    
                    draw_ai_debug(player);
                }
                
                if (hover_gem.type != BLOCK.NONE && hover_gem.falling == false) {
                    var rect_x1 = player.board_x_offset + (hover_i * gem_size);
                    var rect_y1 = (hover_j * gem_size) + player.global_y_offset;
                    var rect_x2 = rect_x1 + gem_size;
                    var rect_y2 = rect_y1 + gem_size;

                    // ✅ Draw Normally but with Transparency
                    draw_sprite_ext(
                    sprite_for_block(hover_gem.type), 
                    hover_gem.img_number, 
                    rect_x2 - offset, 
                    rect_y2 - offset, 
                    scale, 
                    scale, 
                    0, 
                    c_white, 
                    1);
                    
                    draw_sprite_ext(hover_gem.powerup.sprite, 0, rect_x2 - offset, rect_y2 - offset, scale, scale, 0, c_white, 1);
                    
                    if (player.input.InputType == INPUT.KEYBOARD) {
                        draw_sprite_ext(spr_gem_hovered_border, -1, rect_x2 - offset, rect_y2 - offset, scale, scale, 0, c_white, 1);
                    }
                }
            }
        }
    }
}

