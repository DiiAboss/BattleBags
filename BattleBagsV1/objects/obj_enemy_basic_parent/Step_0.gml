/// @description Enemy Step Event

if !(obj_game_control.game_over_state)
{
	if (global.paused || global.in_upgrade_menu) return;

	handle_damage(self);

	adjust_attack_power(self);

	update_damage_fade(self);

	update_attack_timer(self);

	manage_attack_queue(self);

	check_if_enemy_defeated(self);
}