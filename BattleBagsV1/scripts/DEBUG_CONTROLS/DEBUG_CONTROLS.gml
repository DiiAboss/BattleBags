// Script Created By DiiAboss AKA Dillon Abotossaway
function enable_debug_controls(_self, hover_x, hover_y, debug_active = true)
{
	// 🌟 Horizontal Destruction
	if (keyboard_check_pressed(ord("L"))) { 
	    destroy_blocks_in_direction_from_point(_self, hover_x, hover_y, +1, 0); // 🔴 Right
	}
	if (keyboard_check_pressed(ord("J"))) { 
	    destroy_blocks_in_direction_from_point(_self, hover_x, hover_y, -1, 0); // 🔵 Left
	}

	// 🌟 Vertical Destruction
	if (keyboard_check_pressed(ord("I"))) { 
	    destroy_blocks_in_direction_from_point(_self, hover_x, hover_y, 0, -1); // 🔼 Up
	}
	if (keyboard_check_pressed(ord("K"))) { 
	    destroy_blocks_in_direction_from_point(_self, hover_x, hover_y, 0, +1); // 🔽 Down
	}

	// 🌟 Diagonal Destruction
	if (keyboard_check_pressed(ord("U"))) { 
	    destroy_blocks_in_direction_from_point(_self, hover_x, hover_y, -1, -1); // 🔼🔵 Top-Left
	}
	if (keyboard_check_pressed(ord("O"))) { 
	    destroy_blocks_in_direction_from_point(_self, hover_x, hover_y, +1, -1); // 🔼🔴 Top-Right
	}
	if (keyboard_check_pressed(ord("M"))) { 
	    destroy_blocks_in_direction_from_point(_self, hover_x, hover_y, -1, +1); // 🔽🔵 Bottom-Left
	}
	if (keyboard_check_pressed(ord("."))) { 
	    destroy_blocks_in_direction_from_point(_self, hover_x, hover_y, +1, +1); // 🔽🔴 Bottom-Right
	}

if (keyboard_check_pressed(vk_space)) {
    //spawn_2x2_block(_self, hover_x, hover_y, BLOCK.RED); // Spawns a big RED block
}
	if (keyboard_check_pressed(vk_shift)) {
		toss_down_row(_self, true);
	}

	if keyboard_check_pressed(ord("E")) {
		activate_bomb_gem(_self, hover_x, hover_y);
	}

	if keyboard_check_pressed(ord("W")) {
		colorize_column(_self, hover_x, 2);
	}

	if keyboard_check_pressed(ord("D")) {
		colorize_row(_self, hover_y, 2);
	}

	if keyboard_check_pressed(ord("A")) {
		freeze_block(_self, hover_x, hover_y);
	}

	if (keyboard_check_pressed(ord("R"))) {
	    increase_color_spawn(BLOCK.RED, 1);
	}

	if (keyboard_check_pressed(ord("U"))) {
		bring_up_upgrade_menu();
	}

	if (keyboard_check_pressed(ord("Q"))) {

		// Increase Bomb spawn rate by 2
		adjust_powerup_weights(POWERUP.BOMB, 2);

		// Increase Wild Potion spawn rate by 5
		adjust_powerup_weights(POWERUP.EXP, 5);
	}
	
	if (keyboard_check_pressed(ord("1"))) {
		increase_player_max_hearts(_self, 1);
	}
	if (keyboard_check_pressed(ord("2"))) {
	    toss_down_shape(_self, "h_2x1");
	}
	if (keyboard_check_pressed(ord("3"))) {
	    toss_down_shape(_self, "triangle_down_3x3");
	}
	if (keyboard_check_pressed(ord("4"))) {
	    toss_down_shape(_self, "cross");
	}
	if (keyboard_check_pressed(ord("5"))) {
	    toss_down_shape(_self, "x_shape");
	}

	if (keyboard_check(ord("F")))
	{
		_self.fight_for_your_life = true;
	}

	if keyboard_check_pressed(vk_alt)
	{
		_self.target_experience_points += 100;
	}
	
	if (keyboard_check_pressed(ord("0"))) {
    add_new_column(self);
}
}