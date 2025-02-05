/// @description Insert description here
/// @description Enemy Behavior & Attack System

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
// ✅ ENEMY ATTACK TIMER - SELECTS ATTACK AND ADDS TO QUEUE
// ----------------------------------
if (attack_timer >= max_attack_timer) {
    total_attacks += 1;
    attack_timer = 0; // Reset attack timer
}

if (attack_timer == 0) { 
    // ✅ SELECT NEXT ATTACK (DOES NOT EXECUTE YET)
    if (total_attacks % attacks_until_special_attack == 0) {
        enemy_attack_special(self, "triangle_down_3x3");
    } else {
        enemy_attack_basic(self, obj_game_control);
    }
	
	enemy_attack_ready = true; // ✅ Mark that an attack has been selected
}

// ✅ Always increase attack timer
attack_timer += global.enemy_timer_game_speed * (obj_game_control.game_speed_default / global.gameSpeed);

// ----------------------------------
// ✅ QUEUED ATTACK SYSTEM - RELEASE ATTACKS EVERY 10 FRAMES
// ----------------------------------
if (enemy_attack_ready && obj_game_control.combo > 0) {
    attack_queue_active = true; // ✅ Track that an attack was delayed
}

if (attack_queue_active && obj_game_control.combo == 0) {
    if (ds_list_size(global.enemy_attack_queue) > 0) {
        if (queued_attack_timer >= max_queue_attack_timer) {
            var attack_to_execute = ds_list_find_value(global.enemy_attack_queue, 0);
            ds_list_delete(global.enemy_attack_queue, 0);
            
            toss_down_shape(obj_game_control, attack_to_execute, true);
            queued_attack_timer = 0; // Reset timer
            
            // ✅ Attack queue is now empty, resume normal attacks
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









