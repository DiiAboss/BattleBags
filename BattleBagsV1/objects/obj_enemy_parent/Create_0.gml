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

function create_enemy_attack(_self, _enemy_attack, _chance)
{
	return 
	{
		attack: _enemy_attack,
		chance: _chance,
		
	}
}

attack_random = true;

attack_array = [ENEMY_ATTACK.regular_1x1, ENEMY_ATTACK.regular_1x2];

block_weakness_array = [];
block_strength_array = [];


hp = 999999;
max_hp = 999999;


defence = 0;
attack  = 1; // How many blocks they add to each attack, 

function basic_enemy_attack(_self, _size)
{
	var _attack_array = [];
	
	switch (_size)
	{
		case 1:
			array_push(_attack_array, ENEMY_ATTACK.regular_1x1);
			//toss_down_shape(self, "single_1x1")
		break;
		case 2:
			array_push(_attack_array, ENEMY_ATTACK.regular_1x2);
			array_push(_attack_array, ENEMY_ATTACK.regular_2x1);
		break;
		case 3:
		break;
		case 4:
		break;
	}
}

player_current_level = 0;



attack_timer = 0;
max_attack_timer = 30;


incoming_damage = 0;
total_damage = 0;
damage_timer = 0;
max_damage_timer = 60;

damage_alpha = 0;

