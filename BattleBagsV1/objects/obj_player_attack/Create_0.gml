/// @description Insert description here
// You can write your code in this editor
target = noone;

ef_timer = 5;
max_ef_timer = ef_timer;
type = -1;
powerup = -1;
color = c_white;
spd = 8;
damage = obj_game_control.combo + 1;

alarm[0] = 600;

if (instance_exists(obj_enemy_parent))
{
	target = instance_nearest(x, y, obj_enemy_parent);
	direction = point_direction(x, y, target.x, target.y)
}
else
{
	instance_destroy();
}
