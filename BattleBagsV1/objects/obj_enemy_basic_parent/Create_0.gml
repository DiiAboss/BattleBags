/// @description
/// @description Basic Enemy Parent - Governs basic enemy behavior.
/// This should be inherited by standard enemies.

/// ✅ Attack Queue Timers
queued_attack_timer = 0;
max_queued_attack_timer = 300;

/// ✅ Enemy Stats
hp = 100;
max_hp = 100;
defense = 0;
attack_power = 1;
gold_reward = 10;
exp_reward = 25;

/// ✅ Attack Timers
enemy_attack_ready = true;
attack_queue_active = true;

attack_timer_increment_mod = 1;
total_attacks = 1;
attack_timer = 0;
max_attack_timer = 180;
default_attack_power = 1;

attacks_until_special_attack = 3;
special_attack_patterns = ["triangle_down_3x3"];

/// ✅ Damage Tracking
incoming_damage = 0;
total_damage = 0;
damage_timer = 0;
max_damage_timer = 20;
damage_alpha = 0;

/// ✅ Attack Patterns
attack_patterns = [
    ENEMY_ATTACK.REGULAR_1X1,
    ENEMY_ATTACK.REGULAR_1X2,
    ENEMY_ATTACK.REGULAR_2X1,
    ENEMY_ATTACK.REGULAR_2X2
];

/// ✅ Attack Preview System
enemy_attack = "triangle_down_3x3";
grid_width = 5;
enemy_attack_preview = array_create(5);

for (var i = 0; i < 5; i++) {
    enemy_attack_preview[i] = array_create(grid_width, BLOCK.NONE);
}

/// ✅ Preview Timers
preview_build_timer = 0;
preview_blocks_built = 0;

attack_to_execute = -1;
pending_attack  = -1;
target_blocks = ds_list_create();


targetted = false;
my_sprite = spr_test_dummy;