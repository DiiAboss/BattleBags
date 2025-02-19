/// @description Handles enemy damage when hit by player attacks

function create_enemy(start_x, start_y)
{
    var max_health = 100;
    var level = 1;
    
    var enemy_struct =
    {
        enemy_name:         "TEST_DUMMY_000",
        enemy_description:  "Used in testing, has all attacks equipped by default",
        level: level,
        hp:     max_health,
        max_hp: max_health,
        basic_attacks:   undefined,
        special_attacks: undefined,
        my_sprite:       spr_test_dummy,
        my_img:       0,
        attack_timer: 0,
        max_attack_timer: 0,
        exp_drop: 0,
        gold_drop: 0,
        is_boss: false,
        click_shield: 0,
        click_shield_spawn: 0,
        click_shield_max_spawn: 10,
        my_color: c_white,
        targetted: false,
    }
    
    return instance_create_depth(start_x, start_y, -1, obj_enemy_basic_parent, enemy_struct);
}


function init_enemy(enemy_control, start_x, start_y)
{
    var enemy = -1;
    
    enemy = create_enemy(start_x, start_y);
    enemy.basic_attacks = ds_list_create();
    enemy.special_attacks = ds_list_create();
    
    return enemy;
}


function assign_attack_to_enemy(enemy, attack, special = false)
{
    if (special == false)
    {
        ds_list_add(enemy.basic_attacks, attack);
    }
    else {
        ds_list_add(enemy.special_attacks, attack)
    }
}

function destroy_enemy(enemy)
{
    with (enemy)
    {
        ds_list_destroy(basic_attacks);
        ds_list_destroy(special_attacks);
        instance_destroy();        
    }
}

function enemy_apply_damage(enemy)
{
    if (place_meeting(enemy.x, enemy.y, obj_player_attack))
    {
        var incoming = instance_place(enemy.x, enemy.y, obj_player_attack);
        var incoming_damage = incoming.damage;
        
        
        if (enemy.shield_amount > 0)
        {
            enemy.shield_amount -= 1;
        }
        else {
            enemy.hp -= incoming_damage;
            enemy.damage_timer = enemy.max_damage_timer;
            enemy.total_damage += incoming_damage;
            enemy.damage_alpha = 1;
        }
        
        with (incoming) instance_destroy();
    }
}






function handle_damage(_self) {
    if (place_meeting(_self.x, _self.y, obj_player_attack)) {
        var incoming = instance_nearest(_self.x, _self.y, obj_player_attack);

        if (_self.shield_amount > 0)
        {
            shield_amount --;
        }
        else {
            _self.hp -= incoming.damage;
            _self.damage_timer = _self.max_damage_timer;
            _self.total_damage += incoming.damage;
            _self.damage_alpha = 1;
        }

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
