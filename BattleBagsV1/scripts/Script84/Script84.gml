function draw_player_grid(_self, player)
{
    var max_players = _self.max_players;
    
    draw_set_color(c_white);
    draw_set_alpha(1);
    
    var board_x_offset = 0;
    var gem_size = 48;
    var global_y_offset = 0;
    var offset = 32;
    var darken_alpha = 1;
    
    
    var player_grid = player.grid;
    board_x_offset = 96 + (player.id * (9 * gem_size));
    
    // 🔹 Draw player grid properly
    for (var i = 0; i < 8; i++) {
        for (var j = 0; j < bottom_playable_row; j++) {
            if (!is_undefined(player_grid[i, j]) && player_grid[i, j].type != BLOCK.NONE) {
                var gem = player_grid[i, j];
                gem.x_scale = 0.75;
                gem.y_scale = 0.75;
                var draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
                var draw_y = (j * gem_size) + global_y_offset + gem.offset_y + offset - 256;
                
                draw_sprite_ext(sprite_for_block(gem.type), gem.img_number, draw_x, draw_y, gem.x_scale, gem.y_scale, 0, c_white, 1);
            }
        }
    }  
    
}
