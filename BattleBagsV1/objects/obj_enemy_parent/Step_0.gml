/// @description Insert description here
// You can write your code in this editor

	// ✅ Stop everything except the pause check
	if (global.paused) || global.in_upgrade_menu {
		return;
	}


if place_meeting(x, y, obj_player_attack)
{
	var incoming = instance_nearest(x, y, obj_player_attack);
	
	hp -= incoming.damage;
	
	
	damage_timer = max_damage_timer;
	total_damage += incoming.damage;
	damage_alpha = 1;
	
	with (incoming)
	{
		instance_destroy();
	}
}

attack = attack_default + round(obj_game_control.game_speed_default - obj_game_control.game_speed_start);

if (damage_timer > 0)
{
	damage_timer -= 1;
	
	if (damage_timer < 10)
	{
		damage_alpha -= 0.1;
	}
}
else
{
	damage_timer = 0;
	damage_alpha = 0;
}

// ----------------------------------
// ✅ ENEMY ATTACK SYSTEM
// ----------------------------------
if (attack_timer >= max_attack_timer) {
	total_attacks += 1;
	if (ds_list_size(global.enemy_attack_queue) > 0) {
		var attack_to_spawn = ds_list_find_value(global.enemy_attack_queue, 0);
		ds_list_delete(global.enemy_attack_queue, 0);
		toss_down_shape(obj_game_control, attack_to_spawn, true);
		
	}
	attack_timer = 0;
}
else
{

	
	if (attack_timer == 0)
	{
		if (total_attacks % attacks_until_special_attack == 0) {
			//toss_down_shape(obj_game_control, "triangle_down_3x3", true);
			enemy_attack_special(self, "triangle_down_3x3")
		} else {
			enemy_attack_basic(self, obj_game_control);
		}
	}
	
	if (obj_game_control.combo > 0)
	{
		if attack_timer < (max_attack_timer * 0.95)
		{
				attack_timer_increase_mod = global.enemy_timer_game_speed / obj_game_control.game_speed_default;
				attack_timer += attack_timer_increase_mod;
		}
	}
	else
	{
		attack_timer_increase_mod = global.enemy_timer_game_speed / obj_game_control.game_speed_default;
		attack_timer += attack_timer_increase_mod;
	}
}


// ✅ Check Death
if (hp <= 0) {
	enemy_defeated(self, obj_game_control);
}





