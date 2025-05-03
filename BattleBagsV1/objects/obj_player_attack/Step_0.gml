/// @description Insert description here
// You can write your code in this editor
	// ✅ Stop everything except the pause check

rotation_speed += size;

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
    var t_block = instance_create_depth(obj_target.x, y, -1, obj_block_transfer);
    t_block.size += size;
    t_block.rotation_speed = rotation_speed * (choose( 1, -1));
    t_block.color = color;
    instance_destroy();
}
