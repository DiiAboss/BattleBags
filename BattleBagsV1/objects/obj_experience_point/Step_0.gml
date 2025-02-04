/// @description
if (distance_to_point(target_x, target_y) < speed + 0.25)
{
	obj_game_control.experience_points += value;
	instance_destroy();
}
else
{
	effect_create_depth(depth - 99, ef_smoke, x, y, 0.5, c_fuchsia);
	speed += 0.25;
	direction = point_direction(x, y, target_x, target_y);
}