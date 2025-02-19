/// @description Enemy Step Event - Handles attacks, health, and previews.
if (obj_game_control.victory_state) {
    instance_destroy();
}
if (global.paused || global.in_upgrade_menu) return;

// ✅ Handle Damage
if (place_meeting(x, y, obj_player_attack)) {
    var incoming = instance_nearest(x, y, obj_player_attack);
    
    hp -= incoming.damage;
    
    damage_timer = max_damage_timer;
    total_damage += incoming.damage;
    damage_alpha = 1;
    
    with (incoming) instance_destroy();
}

// ✅ Adjust attack power based on game speed
attack_power = default_attack_power + round(obj_game_control.game_speed_default - obj_game_control.game_speed_start);

// ✅ Fade out damage indicator
if (damage_timer > 0) {
    damage_timer -= 1;
    if (damage_timer < 10) {
        damage_alpha -= 0.1;
    }
} else {
    damage_timer = 0;
    damage_alpha = 0;
}

// ✅ Enemy Attack Timer - Select Attack
if (attack_timer >= max_attack_timer) {
    total_attacks += 1;
    attack_timer = 0; // Reset attack timer
}

// ✅ Select Next Attack
if (attack_timer == 0) { 
    if (total_attacks % attacks_until_special_attack == 0) {
        var atk_type = choose(0, 0, 1, 1, 1);
        var atk_final = atk_type;

        if (obj_game_control.player_level > 10) {
            atk_final = choose(atk_type, atk_type, 2);
        }

        if (atk_final == atk_type) {
            self.enemy_attack = (atk_type == 0) ? "triangle_down_3x3" : enemy_attack_freeze(self, obj_game_control);
        } else {
            spawn_puzzle_blocks(obj_game_control);
        }
    } else {
        var atk_type = choose(0, 0, 0, 1);
        self.enemy_attack = (atk_type == 0) ? enemy_attack_basic(self, obj_game_control) : enemy_attack_freeze(self, obj_game_control);
    }

    enemy_attack_ready = true;
    preview_build_timer = 0;
    preview_blocks_built = 0;

    // ✅ Setup preview grid size
    if (ds_map_exists(global.shape_templates, self.enemy_attack)) {
        var attack_shape = ds_map_find_value(global.shape_templates, self.enemy_attack);
        var rows = array_length(attack_shape);
        var cols = array_length(attack_shape[0]);

        enemy_attack_preview = array_create(rows);
        for (var row = 0; row < rows; row++) {
            enemy_attack_preview[row] = array_create(cols, BLOCK.NONE);
        }
    }
}

// ✅ Always increase attack timer
attack_timer += global.enemy_timer_game_speed * (obj_game_control.game_speed_default / global.gameSpeed);

// ✅ Build Preview Block-By-Block
if (enemy_attack_ready && self.enemy_attack != "") {
    preview_build_timer += 1;

    if (ds_map_exists(global.shape_templates, self.enemy_attack)) {
        var attack_shape = ds_map_find_value(global.shape_templates, self.enemy_attack);

        if (is_array(attack_shape)) {
            var rows = array_length(attack_shape);
            var cols = array_length(attack_shape[0]);
            var total_blocks = rows * cols;

            if (preview_build_timer >= (max_attack_timer / total_blocks)) {
                var row = preview_blocks_built div cols;
                var col = preview_blocks_built mod cols;

                if (row < rows && col < cols) {
                    if (attack_shape[row][col] != BLOCK.NONE) {
                        enemy_attack_preview[row][col] = attack_shape[row][col];
                    }
                }

                preview_blocks_built++;
                preview_build_timer = 0;
            }
        } else {
            show_debug_message("ERROR: Invalid attack shape for " + string(self.enemy_attack));
        }
    }
}

// ✅ Queued Attack System - Release attacks every X frames
if (enemy_attack_ready && obj_game_control.combo > 0) {
    attack_queue_active = true;
}

if (attack_queue_active) {
    if (ds_list_size(global.enemy_attack_queue) > 0) {
        if (queued_attack_timer >= max_queued_attack_timer) {
            var attack_to_execute = ds_list_find_value(global.enemy_attack_queue, 0);
            ds_list_delete(global.enemy_attack_queue, 0);
            
            toss_down_shape(obj_game_control, attack_to_execute, true);
            queued_attack_timer = 0;
            
            if (ds_list_size(global.enemy_attack_queue) == 0) {
                attack_queue_active = false;
                enemy_attack_ready = false;
            }
        } else {
            queued_attack_timer += 1;
        }
    }
}

// ✅ Check if enemy is dead
if (hp <= 0){
    enemy_defeated(self, obj_game_control);
}











