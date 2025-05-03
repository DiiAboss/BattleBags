function draw_game_over_state(game_control)
        {
            
            var game_over_ui_x = game_control.game_over_ui_x;
            var game_over_ui_y = game_control.game_over_ui_y;
            var game_over_ui_width = game_control.game_over_ui_width;
            var game_over_ui_height = game_control.game_over_ui_height;
            var game_over_ui_x_2 = game_over_ui_x + game_over_ui_width;
            var game_over_ui_y_2 = game_over_ui_y + game_over_ui_height;
            
            var you_lose_offset = 600;
            
            // ✅ Draw Left Panel
        draw_set_alpha(0.85);
        draw_set_color(c_black);
        draw_rectangle(game_over_ui_x, game_over_ui_y, game_over_ui_x_2, game_over_ui_y_2, false);
        draw_set_alpha(1);
    
        // ✅ Draw "You Lose" Title
        var you_lose_x = game_over_ui_x_2 / 2;
        var you_lose_y = game_over_ui_y + you_lose_offset;
        var you_lose_str = "YOU LOSE";
        
        draw_text_heading_font(you_lose_x, you_lose_y, you_lose_str);
            
            
            var game_over_popping        = game_control.game_over_popping;
            var game_over_block_sprite   = spr_gameOver;
            var game_over_overlay_sprite = spr_enemy_gem_overlay;
            var gem_size                 = game_control.gem_size;
            var board_x_offset           = game_control.board_x_offset;
            
        // ✅ Draw Popping Blocks
        for (var i = 0; i < ds_list_size(game_over_popping); i++) {
            var pop_data = ds_list_find_value(game_over_popping, i);
            var _x = pop_data.x;
            var _y = pop_data.y;
    
            draw_sprite(game_over_block_sprite,   0, (_x * gem_size) + board_x_offset, (_y * gem_size));
            draw_sprite(game_over_overlay_sprite, 0, (_x * gem_size) + board_x_offset, (_y * gem_size));
        }
            
            var game_over_show_options = game_control.game_over_show_option;
            var game_over_option_selected = game_control.game_over_option_selected;
            
        // ✅ Draw Options After Blocks Have Popped
        if (game_over_show_options) {
            var restart_x     = game_over_ui_x + 50;
            var restart_y     = game_over_ui_y + 350;
            var menu_x        = game_over_ui_x + 50;
            var menu_y        = game_over_ui_y + 420;
            var button_width  = 300;
            var button_height = 50;

            
            // ✅ Highlight button on hover
            if (game_over_option_selected == 0) draw_set_color(c_white);
            else draw_set_color(c_grey); 
                
            var rest_x = restart_x + button_width  / 2;
            var rest_y = restart_y + button_height / 2;
            var restart_str = "RESTART";
            
            draw_text_text_font(rest_x, rest_y, restart_str);
                
            if (game_over_option_selected == 1) draw_set_color(c_white);
            else draw_set_color(c_grey);
                
            var mmenu_x = menu_x + button_width  / 2;
            var mmenu_y = menu_y + button_height / 2;
            var mmenu_str = "MAIN MENU";
            
            draw_text_text_font(mmenu_x, mmenu_y, mmenu_str);
        }
        }
