/// @description Insert description here
// You can write your code in this editor

enemy_name = "";
enemy_description = "";



enemies_defeated = 0;
base_exp_earned = 0;
exp_mod         = 0;

time = 0;
highest_combo = 0;
gold_collected = 0;

enemy_spawn_pos_x = 1344;
enemy_spawn_pos_y = 928;

enemy_array = [
instance_create_depth(enemy_spawn_pos_x, enemy_spawn_pos_y, depth, obj_enemy_basic_parent)
];

amount_of_enemies = array_length(enemy_array);