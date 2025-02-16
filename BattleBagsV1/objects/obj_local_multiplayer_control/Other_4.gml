/// @description

if (room == rm_local_multiplayer_game)
{
    for (var i = 0; i < max_players; i++) {
        random_set_seed(random_seed);
        player_grid[i] = spawn_random_blocks_in_array(player_grid[i], 6);
    }
}

