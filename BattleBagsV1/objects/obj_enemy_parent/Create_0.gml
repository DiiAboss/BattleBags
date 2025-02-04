/// @description Insert description here
// You can write your code in this editor

enum ENEMY_ATTACK
{
	regular_1x1 = 0,
	regular_1x2 = 1,
	regular_1x3 = 2,
	regular_1x4 = 3,
	regular_1x5 = 4,
	regular_1x6 = 5,
	regular_1x7 = 6,
	regular_1x8 = 7,
	regular_2x1 = 8,
	regular_2x2 = 9,
	regular_2x3 = 10,
	regular_2x4 = 11,
	regular_2x5 = 12,
	regular_2x6 = 13,
	regular_2x7 = 14,
	regular_2x8 = 15,
	regular_3x1 = 16,
	regular_3x2 = 17,
	regular_3x3 = 18,
	regular_3x4 = 19,
	regular_3x5 = 20
}

queued_attack_timer = 0;
max_queue_attack_timer = 60;

// ----------------------------------
// ✅ Enemy Stats
// ----------------------------------
hp = 100;
max_hp = 100;
defence = 0;
attack = 1; // 🔥 How many blocks are spawned in each attack
gold_reward = 10;
exp_reward = 5;

// ----------------------------------
// ✅ Attack Timer
// ----------------------------------
enemy_attack_ready = true; // ✅ Mark that an attack has been selected
attack_queue_active = true; // ✅ Track that an attack was delayed

attack_timer_increase_mod = 1;
total_attacks = 1;
attack_timer = 0;
max_attack_timer = 600; // Attacks every 10 seconds
attack_default = 1;

attacks_until_special_attack = 3; // Set this so after a certain amount of attacks, do a special attack;
special_attack_patterns = [
"triangle_down_3x3",
];


// ----------------------------------
// ✅ Damage Tracking
// ----------------------------------
incoming_damage = 0;
total_damage = 0;
damage_timer = 0;
max_damage_timer = 60;
damage_alpha = 0;

attack_patterns = [
	ENEMY_ATTACK.regular_1x1,
	ENEMY_ATTACK.regular_1x2,
	ENEMY_ATTACK.regular_2x1,
	ENEMY_ATTACK.regular_2x2
];
