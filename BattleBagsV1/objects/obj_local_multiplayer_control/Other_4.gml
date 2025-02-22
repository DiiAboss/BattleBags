/// @description

if (room == rm_local_multiplayer_game)
{
    draw_set_halign(fa_left);
    for (var i = 0; i < ds_list_size(global.player_list); i++) {
        random_set_seed(random_seed);
        var player = ds_list_find_value(global.player_list, i);
        player.grid = spawn_random_blocks_in_array(player.grid, 6);
    }
}

