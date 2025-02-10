/// @description Enemy Step Event - Attack Preview System

// ✅ Stop everything except the pause check
if (global.paused || global.in_upgrade_menu) {
    return;
}

// ----------------------------------
// ✅ DAMAGE HANDLING
// ----------------------------------
if (place_meeting(x, y, obj_player_attack)) {
    var incoming = instance_nearest(x, y, obj_player_attack);
    
    hp -= incoming.damage;
    
    damage_timer = max_damage_timer;
    total_damage += incoming.damage;
    damage_alpha = 1;
    
    with (incoming) {
        instance_destroy();
    }
}

// ✅ Update attack strength based on game speed
attack = attack_default + round(obj_game_control.game_speed_default - obj_game_control.game_speed_start);

// ✅ Fade damage indicator
if (damage_timer > 0) {
    damage_timer -= 1;
    if (damage_timer < 10) {
        damage_alpha -= 0.1;
    }
} else {
    damage_timer = 0;
    damage_alpha = 0;
}

// ----------------------------------
// ✅ ENEMY ATTACK TIMER - SELECT ATTACK
// ----------------------------------
if (attack_timer >= max_attack_timer) {
    total_attacks += 1;
    attack_timer = 0; // Reset attack timer
}

if (attack_timer == 0) { 
    // ✅ SELECT NEXT ATTACK
    if (total_attacks % attacks_until_special_attack == 0) {
		var atk = choose(0, 0, 1, 1, 1);
		var atk2 = atk;
		if (obj_game_control.player_level > 10)
		{
			atk2 = choose(atk, atk, 2);
		}
		
		if (atk2 == atk)
		{
			if (atk == 0)
			{
				self.enemy_attack = "triangle_down_3x3";
			}
			else
			{
				enemy_attack_freeze(self, obj_game_control);
			}
		}
		else
		{
			spawn_puzzle_blocks(obj_game_control);
		}
    } else {
		var atk = choose(0,0,0,1);
		if (atk == 0)
		{
			self.enemy_attack = enemy_attack_basic(self, obj_game_control);
			
		}
		else
		{
			enemy_attack_freeze(self, obj_game_control);
		}
    }

    self.enemy_attack_ready = true; // ✅ Mark attack as selected
    self.preview_build_timer = 0;
    self.preview_blocks_built = 0;

    // ✅ Initialize preview array size based on attack
    if (ds_map_exists(global.shape_templates, self.enemy_attack)) {
        var attack_shape = ds_map_find_value(global.shape_templates, self.enemy_attack);
        var rows = array_length(attack_shape);
        var cols = array_length(attack_shape[0]);

        self.enemy_attack_preview = array_create(rows);
        for (var row = 0; row < rows; row++) {
            self.enemy_attack_preview[row] = array_create(cols, BLOCK.NONE);
        }
    }
}

// ✅ Always increase attack timer
attack_timer += global.enemy_timer_game_speed * (obj_game_control.game_speed_default / global.gameSpeed);

// ----------------------------------
// ✅ BUILD PREVIEW BLOCK-BY-BLOCK ABOVE ENEMY
// ----------------------------------
if (self.enemy_attack_ready && self.enemy_attack != "") {
    self.preview_build_timer += 1;

    if (ds_map_exists(global.shape_templates, self.enemy_attack)) {
        var attack_shape = ds_map_find_value(global.shape_templates, self.enemy_attack);

        if (is_array(attack_shape)) {
            var rows = array_length(attack_shape);
            var cols = array_length(attack_shape[0]);
            var total_blocks = rows * cols;

            if (self.preview_build_timer >= (max_attack_timer / total_blocks)) {
                var row = self.preview_blocks_built div cols;
                var col = self.preview_blocks_built mod cols;

                if (row < rows && col < cols) {
                    if (attack_shape[row][col] != BLOCK.NONE) {
                        self.enemy_attack_preview[row][col] = attack_shape[row][col];
                    }
                }

                self.preview_blocks_built++;
                self.preview_build_timer = 0;
            }
        } else {
            show_debug_message("ERROR: Invalid attack shape for " + string(self.enemy_attack));
        }
    }
}

// ----------------------------------
// ✅ QUEUED ATTACK SYSTEM - RELEASE ATTACKS EVERY 10 FRAMES
// ----------------------------------
if (enemy_attack_ready && obj_game_control.combo > 0) {
    attack_queue_active = true; // ✅ Track that an attack was delayed
}

if (attack_queue_active) {
    if (ds_list_size(global.enemy_attack_queue) > 0) {
        if (queued_attack_timer >= max_queue_attack_timer) {
            var attack_to_execute = ds_list_find_value(global.enemy_attack_queue, 0);
            ds_list_delete(global.enemy_attack_queue, 0);
            
            toss_down_shape(obj_game_control, attack_to_execute, true);
            queued_attack_timer = 0; // Reset timer
            
            if (ds_list_size(global.enemy_attack_queue) == 0) {
                attack_queue_active = false;
                enemy_attack_ready = false;
            }
        } else {
            queued_attack_timer += 1; // Increment timer
        }
    }
}

// ✅ Check if the enemy is dead
if (hp <= 0) {
    enemy_defeated(self, obj_game_control);
}










