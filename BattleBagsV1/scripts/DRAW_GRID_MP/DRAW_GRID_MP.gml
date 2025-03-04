function draw_player_grid(mp_control, player)
{
    var max_players = mp_control.max_players;
    
    draw_set_color(c_white);
    draw_set_alpha(1);
    
    // Set gem size based on player count (if needed)
    if (max_players <= 3) {
        mp_control.gem_size = 64;
    }
    
    var gem_size = mp_control.gem_size;
    var global_y_offset = player.global_y_offset;
    var offset = 32;
    var darken_alpha = player.darken_alpha;
    
    // Board width in pixels
    var board_width = (gem_size * 8) + offset * 2;
    
    // Handle positioning for different player counts
    var spacing = 0;
    var base_x = 0;
    
    switch (max_players) {
        case 2:
            spacing = 256; // Big gap for 2 players
            base_x = (room_width - (board_width * 2) - spacing) * 0.5;
            break;
        case 3:
            spacing = 48; // Moderate gap for 3 players
            base_x = (room_width - (board_width * 3) - (spacing * 2)) * 0.5 + 32;
            break;
        case 4:
            spacing = 32; // Smaller gap for 4 players
            base_x = (room_width - (board_width * 4) - (spacing * 3)) * 0.5 + 32;
            break;
    }
    
    // Final X position for this player
    var board_x_offset = base_x + (player._id * (board_width + spacing));
    player.board_x_offset = board_x_offset;

    draw_text(board_x_offset, 100, string(player.board_x_offset));

    var player_grid = player.grid;

    // 🔹 Draw player grid
    for (var i = 0; i < 8; i++) {
        for (var j = 0; j <= bottom_playable_row; j++) {
            if (!is_undefined(player_grid[i, j]) && player_grid[i, j].type != BLOCK.NONE) {
                var gem = player_grid[i, j];
                gem.x_scale = gem_size / 64;
                gem.y_scale = gem_size / 64;

                if gem.falling {
                    var percent = clamp(gem.fall_delay / gem.max_fall_delay, 0, 1);
                    gem.draw_y = 64 * percent;
                    gem.offset_x = 0;
                } else {
                    gem.draw_y = 0;
                }

                var draw_x = board_x_offset + (i * gem_size) + offset + gem.offset_x;
                var draw_y = (j * gem_size) + global_y_offset + gem.offset_y + offset + gem.draw_y;
                var alpha = 1;

                if (j == bottom_playable_row) alpha = darken_alpha;

                draw_sprite_ext(
                    sprite_for_block(gem.type), 
                    gem.img_number, 
                    draw_x, 
                    draw_y, 
                    gem.x_scale, 
                    gem.y_scale, 
                    0, 
                    c_white, 
                    alpha
                );

                draw_sprite_ext(gem.powerup.sprite, 0, draw_x, draw_y, gem.x_scale, gem.y_scale, 0, c_white, alpha);
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