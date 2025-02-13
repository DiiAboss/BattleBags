
function game_over_screen(_self, game_over_state)
{
    if (game_over_state) {
        _self.game_over_timer++;
    
        if (ds_list_size(_self.game_over_popping) > 0) {
            var pop_data = ds_list_find_value(_self.game_over_popping, 0);
    
            if (_self.game_over_timer >= pop_data.pop_delay) {
                var _x = pop_data.x;
                var _y = pop_data.y;
    
                // ✅ Visual pop effect
                effect_create_depth(-99, ef_smoke, (_x * _self.gem_size) + _self.board_x_offset, (_y * _self.gem_size), 2, c_gray);
                
                var _pitch = clamp(1 - (0.01 * _self.game_over_blocks_popped), 0.1, 1);
                var _gain = clamp(0.5 - (0.01 * _self.game_over_blocks_popped), 0.1, 1);
                    

                audio_play_sound(snd_pop_test_1, 10, false, _gain, 0, _pitch);
               

                // ✅ Remove the block
                _self.game_over_blocks_popped ++;
                destroy_block(self, _x, _y);
                ds_list_delete(_self.game_over_popping, 0);
    
                // ✅ Speed up popping over time
                _self.game_over_pop_delay = max(1, _self.game_over_pop_delay - 0.5);
            }
        } else {
            // ✅ All blocks have popped, show menu options
            _self.game_over_show_options = true;
        }
    
        // ✅ Handle Mouse Input for Menu Options
        if (_self.game_over_show_options) {
            var mx = mouse_x;
            var my = mouse_y;
    
            var restart_x = game_over_ui_x + 50;
            var restart_y = game_over_ui_y + 350;
            var menu_x = game_over_ui_x + 50;
            var menu_y = game_over_ui_y + 420;
            var button_width = 300;
            var button_height = 50;
    
            if (mx >= restart_x && mx <= restart_x + button_width && my >= restart_y && my <= restart_y + button_height) {
                _self.game_over_option_selected = 0;
                if (mouse_check_button_pressed(mb_left)) {
                    room_restart();
                }
            } else if (mx >= menu_x && mx <= menu_x + button_width && my >= menu_y && my <= menu_y + button_height) {
                _self.game_over_option_selected = 1;
                if (mouse_check_button_pressed(mb_left)) {
                    room_goto(rm_main_menu);
                }
            } else {
                _self.game_over_option_selected = -1; // Reset selection if not hovering over buttons
            }
        }
    }
}
