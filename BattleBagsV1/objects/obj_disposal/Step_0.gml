/// @description
if (place_meeting(x, y, obj_deposit_block))
{
	image_index = 1;
	
	with (instance_nearest(x, y, obj_deposit_block))
	{
		instance_destroy();
		effect_create_above(ef_firework, x, y, 1, color);
	}
}