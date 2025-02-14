/// @description
amount_of_enemies = instance_number(obj_enemy_basic_parent);

if (amount_of_enemies <= 0)
{
	enemy_array[0] = instance_create_depth(enemy_spawn_pos_x, enemy_spawn_pos_y, depth, obj_enemy_basic_parent);
}
