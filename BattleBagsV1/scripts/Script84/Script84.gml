function draw_player_grid(mp_control, player)
{
    var max_players = mp_control.max_players;
    
    draw_set_color(c_white);
    draw_set_alpha(1);
    
    var board_x_offset = 0;
    var gem_size = mp_control.gem_size;
    var global_y_offset = player.global_y_offset;
    var offset = 32;
    var darken_alpha = 1;
    
    
    var player_grid = player.grid;
    board_x_offset = 96 + (player.id * (9 * gem_size));
    
    player.board_x_offset = board_x_offset;
    
    draw_text(board_x_offset, 100, string(player.input.InputType));
    
    // 🔹 Draw player grid properly
    for (var i = 0; i < 8; i++) {
        for (var j = 0; j < bottom_playable_row; j++) {
            if (!is_undefined(player_grid[i, j]) && player_grid[i, j].type != BLOCK.NONE) {
                var gem = player_grid[i, j];
                gem.x_scale = gem_size / 64;
                gem.y_scale = gem_size / 64;
                var draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
                var draw_y = (j * gem_size) + global_y_offset + gem.offset_y + offset;
                
                draw_sprite_ext(sprite_for_block(gem.type), gem.img_number, draw_x, draw_y, gem.x_scale, gem.y_scale, 0, c_white, 1);
                draw_sprite_ext(gem.powerup.sprite, 0, draw_x, draw_y, gem.x_scale, gem.y_scale, 0, c_white, 1);
                
            }
        }
    }  
    
}
