/// @description
for (var i = 0; i < total_enemies; i++) {
        var player = enemy_list[i];
        
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
                }
            }
        }
    }
