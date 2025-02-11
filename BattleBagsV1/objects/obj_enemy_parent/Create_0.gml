/// @description Enemy Object - Handles attacks, health, and previews.

enum ENEMY_ATTACK {
    REGULAR_1X1 = 0, REGULAR_1X2 = 1, REGULAR_1X3 = 2, REGULAR_1X4 = 3,
    REGULAR_1X5 = 4, REGULAR_1X6 = 5, REGULAR_1X7 = 6, REGULAR_1X8 = 7,
    REGULAR_2X1 = 8, REGULAR_2X2 = 9, REGULAR_2X3 = 10, REGULAR_2X4 = 11,
    REGULAR_2X5 = 12, REGULAR_2X6 = 13, REGULAR_2X7 = 14, REGULAR_2X8 = 15,
    REGULAR_3X1 = 16, REGULAR_3X2 = 17, REGULAR_3X3 = 18, REGULAR_3X4 = 19,
    REGULAR_3X5 = 20
}

// ✅ Attack Queue Timers
queued_attack_timer = 0;
max_queued_attack_timer = 20;

// ✅ Enemy Stats
hp = 100;
max_hp = 100;
defense = 0;
attack_power = 1;  // Number of blocks spawned in each attack
gold_reward = 10;
exp_reward = 5;

// ✅ Attack Timers
enemy_attack_ready = true;
attack_queue_active = true;

attack_timer_increment_mod = 1;
total_attacks = 1;
attack_timer = 0;
max_attack_timer = 300;  // Attack every 5 seconds
default_attack_power = 1;

attacks_until_special_attack = 3;  // Every X attacks, do a special attack
special_attack_patterns = ["triangle_down_3x3"];

// ✅ Damage Tracking
incoming_damage = 0;
total_damage = 0;
damage_timer = 0;
max_damage_timer = 60;
damage_alpha = 0;

// ✅ Attack Patterns
attack_patterns = [
    ENEMY_ATTACK.REGULAR_1X1,
    ENEMY_ATTACK.REGULAR_1X2,
    ENEMY_ATTACK.REGULAR_2X1,
    ENEMY_ATTACK.REGULAR_2X2
];

// ✅ Enemy Attack Type
self.enemy_attack = "triangle_down_3x3";
width = 5;

// ✅ Attack Preview Grid (5 rows max)
enemy_attack_preview = array_create(5);
for (var i = 0; i < 5; i++) {
    enemy_attack_preview[i] = array_create(width, BLOCK.NONE);
}

// ✅ Attack Preview Timer
preview_build_timer = 0;
preview_blocks_built = 0;

target_block = [-1, -1];  // Tracks the current block the enemy is aiming at
