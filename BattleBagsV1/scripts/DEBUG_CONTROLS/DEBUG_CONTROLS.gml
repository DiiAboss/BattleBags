// Script Created By DiiAboss AKA Dillon Abotossaway
function enable_debug_controls(_self, hover_x, hover_y, debug_active = false)
{
	if !debug_active return;
	//  Horizontal Destruction
	if (keyboard_check_pressed(ord("L"))) { 
	    var final_pos = [-1, -1];
		final_pos = destroy_blocks_in_direction_from_point(_self, hover_x, hover_y, +1, 0); // Right
		
		var bow_obj = instance_create_depth(board_x_offset + hover_x * _self.gem_size, (hover_y * _self.gem_size) + _self.global_y_offset + 32, depth-99, obj_bow);
		
		bow_obj.final_pos = final_pos;
		
	}
	if (keyboard_check_pressed(ord("J"))) { 
		
			    var final_pos = [-1, -1];
		final_pos = destroy_blocks_in_direction_from_point(_self, hover_x, hover_y, -1, 0); // Left
		
		var bow_obj = instance_create_depth(board_x_offset + hover_x * _self.gem_size, (hover_y * _self.gem_size) + _self.global_y_offset + 32, depth-99, obj_bow);
		
		bow_obj.final_pos = final_pos;
	}
    
    if (keyboard_check_pressed(ord("T")))
    {
        destroy_rows_from_bottom(self, 1);
    }
    
	
	if (keyboard_check_pressed(vk_backspace))
	{
		trigger_final_game_over(self);
	}
    
    if (keyboard_check_pressed(vk_insert))
    {
        victory_state = true;
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

if (keyboard_check_pressed(vk_end)) {
    spawn_2x2_block(_self, hover_x, hover_y, BLOCK.RED); // Spawns a big RED block
}
if (keyboard_check_pressed(vk_home)) {
    spawn_mega_block(self, irandom_range(0, _self.width), 4, "line_1x3"); // Spawn **1x3 Line Mega Block**
}
	if (keyboard_check_pressed(vk_shift)) {
		//toss_down_row(_self, true);
		play_next_song();
	}
		if (keyboard_check(vk_shift)) {
		//toss_down_row(_self, true);
		//play_next_song();
		//_self.global_y_offset = -63;
		//_self.shift_speed = 0;
	}
	
	if (keyboard_check_pressed(vk_tab))
	{
		spawn_puzzle_blocks(self);
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
		_self.target_experience_points += 10000;
	}
	
	if (keyboard_check_pressed(ord("0"))) {
    add_new_column(self);
}
}