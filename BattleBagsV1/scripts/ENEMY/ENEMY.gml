/// @description Handles enemy damage when hit by player attacks
function handle_damage(_self) {
    if (place_meeting(_self.x, _self.y, obj_player_attack)) {
        var incoming = instance_nearest(_self.x, _self.y, obj_player_attack);

        _self.hp -= incoming.damage;
        _self.damage_timer = _self.max_damage_timer;
        _self.total_damage += incoming.damage;
        _self.damage_alpha = 1;

        with (incoming) instance_destroy();
    }
}

/// @description Adjusts enemy attack power based on game speed
function adjust_attack_power(_self) {
    _self.attack_power = _self.default_attack_power + round(
        obj_game_control.game_speed_default - obj_game_control.game_speed_start
    );
}

/// @description Handles the damage fading effect
function update_damage_fade(_self) {
    if (_self.damage_timer > 0) {
        _self.damage_timer -= 1;
        if (_self.damage_timer < 10) {
            _self.damage_alpha -= 0.1;
        }
    } else {
        _self.damage_timer = 0;
        _self.damage_alpha = 0;
    }
}

/// @description Manages the attack timer and selects the next attack
function update_attack_timer(_self) {
    if (_self.attack_timer >= _self.max_attack_timer) {
        _self.total_attacks += 1;
        _self.attack_timer = 0; 
        select_enemy_attack(_self); // ✅ Calls attack selection (can be overridden)
    }
    _self.attack_timer += global.enemy_timer_game_speed;
}

/// @description Manages the attack queue system
function manage_attack_queue(_self) {
    if (_self.enemy_attack_ready && obj_game_control.combo == 0) {
        _self.attack_queue_active = true;
    }

    if (_self.attack_queue_active) {
        process_attack_queue(_self);
    }
}

/// @description Handles enemy defeat logic
function check_if_enemy_defeated(_self) {
    if (_self.hp <= 0) {
        enemy_defeated(_self, obj_game_control);
    }
}
