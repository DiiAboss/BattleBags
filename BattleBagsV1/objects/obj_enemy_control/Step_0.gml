/// @description
amount_of_enemies = instance_number(obj_enemy_basic_parent);

if (amount_of_enemies <= 0)
{
	enemy_array[0] = instance_create_depth(enemy_spawn_pos_x, enemy_spawn_pos_y, depth, obj_enemy_basic_parent);
}

if (attack_preview_active) {
    // 🔥 Set Camera to Focus Above Enemy
    var enemy_x = enemy_spawn_pos_x - 400; 
    var enemy_y = enemy_spawn_pos_y - 600; // Adjust height to go above head

    attack_preview_box_x = lerp(attack_preview_box_x, enemy_x - (attack_preview_box_width / 2), 0.1);
    attack_preview_box_y = lerp(attack_preview_box_y, enemy_y - (attack_preview_box_height / 2), 0.1);

    // 🔥 Apply Smooth Alpha Transition
    attack_preview_alpha = min(attack_preview_alpha + 0.05, 1);
} else {
    attack_preview_alpha = max(attack_preview_alpha - 0.05, 0);
}

// 🔹 Update Camera Position
camera_set_view_pos(preview_camera, attack_preview_box_x, attack_preview_box_y);
camera_set_view_size(preview_camera, attack_preview_box_width, attack_preview_box_height);

if (keyboard_check_pressed(vk_space))
{
    if !enemy_is_attacking
    {
        enemy_is_attacking = true;
    }
    else {
        enemy_is_attacking = false;
    }
    
}

if (enemy_is_attacking) {
    attack_preview_active = true;
} else {
    attack_preview_active = false;
}