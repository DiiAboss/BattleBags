/// @description Insert description here
// You can write your code in this editor
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