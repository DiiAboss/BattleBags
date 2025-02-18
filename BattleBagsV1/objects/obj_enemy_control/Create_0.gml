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



attack_preview_box_x = 1000;
attack_preview_box_y = 500;

attack_preview_box_width = 400;
attack_preview_box_height = 300;

attack_preview_active = true;
attack_preview_alpha = 0;
enemy_is_attacking = false;
preview_camera = camera_create_view(attack_preview_box_x, attack_preview_box_y, attack_preview_box_width, attack_preview_box_height);

