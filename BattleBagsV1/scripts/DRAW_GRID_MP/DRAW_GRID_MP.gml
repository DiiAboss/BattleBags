function draw_player_grid(mp_control, player)
{
    var max_players = mp_control.max_players;
    
    draw_set_color(c_white);
    draw_set_alpha(1);
    
    if (max_players < 3)
    {
        mp_control.gem_size = 64;
    }
    
    var board_x_offset = 0;
    var gem_size = mp_control.gem_size;
    var global_y_offset = player.global_y_offset;
    var offset = 32;
    var darken_alpha = 1;
    var draw_x_start = room_width / (max_players + 1) - (width * 0.5);
    
    
    var player_grid = player.grid;
    board_x_offset = 96 + ((draw_x_start) * player._id) + (player._id * (9 * gem_size));
    
    player.board_x_offset = board_x_offset;
    
    draw_text(board_x_offset, 100, string(player.board_x_offset));
    
    // 🔹 Draw player grid properly
    for (var i = 0; i < 8; i++) {
        for (var j = 0; j < bottom_playable_row; j++) {
            if (!is_undefined(player_grid[i, j]) && player_grid[i, j].type != BLOCK.NONE) {
                var gem = player_grid[i, j];
                gem.x_scale = gem_size / 64;
                gem.y_scale = gem_size / 64;
                
                if gem.falling 
                {
                    var percent =  clamp(gem.fall_delay / gem.max_fall_delay, 0, 1);
                    gem.draw_y = 64 * percent;
                }
                else {
                    gem.draw_y = 0;
                }
                
                
                var draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
                var draw_y = (j * gem_size) + global_y_offset + gem.offset_y + offset + gem.draw_y;
                
                draw_sprite_ext(sprite_for_block(gem.type), gem.img_number, draw_x, draw_y, gem.x_scale, gem.y_scale, 0, c_white, 1);
                draw_sprite_ext(gem.powerup.sprite, 0, draw_x, draw_y, gem.x_scale, gem.y_scale, 0, c_white, 1);
                
            }
        }
    }  
    
}



function show_hovered_block_stats(player, block_x, block_y)
{
    
    var block = player.grid[block_x, block_y];
    // ✅ OPTIONAL: Show gem info in the corner
    draw_text(player.board_x_offset + 10, player.draw_y_start + 10,
        "Hovering: (" + string(block_x) + ", " + string(block_y) +
        ")\n | Type: " + string(block.type) + 
        "\n | Powerup: " + string(block.powerup) +
        "\n | falling: " + string(block.falling) +
        "\n | popping:  " + string(block.popping)
    );
}