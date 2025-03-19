/// @description Insert description here
// You can write your code in this editor
	// ✅ Stop everything except the pause check

if (x > obj_target.x)
{
    destroy_flag = true;
}


if (global.paused) || global.in_upgrade_menu {
	speed = 0;
	return;
}

else
{

	speed = spd;
	//effect_create_depth(depth, ef_smoke, x, y, 0.5, color);
}


if (obj_game_control.game_over_state)
{
	instance_destroy();
}

if (destroy_flag)
{
    obj_target.c_timer = 0;
    //effect_create_depth(depth, ef_firework, x, y, 1, color);
    instance_create_depth(obj_target.x, y, -1, obj_block_transfer_y);
    instance_destroy();
}
