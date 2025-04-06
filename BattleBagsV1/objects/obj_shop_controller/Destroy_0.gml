/// @description

var player = obj_game_control;

for (var i = 0; i < player.number_of_drones; i++)
{ 
    player.drone_array[i].update_stats();
}
player.block_spawn_rates.update_block_weights();
global.paused = false;
