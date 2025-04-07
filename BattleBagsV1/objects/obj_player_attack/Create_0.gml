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



size = damage * 0.05;

rotation_speed = size;

alarm[0] = 600;

if (instance_exists(obj_target))
{
	target = instance_nearest(x, y, obj_target);
	direction = 0;
}
else
{
	instance_destroy();
}

destroy_flag = false;


