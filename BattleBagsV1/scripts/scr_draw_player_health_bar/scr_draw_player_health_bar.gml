// Script Created By DiiAboss AKA Dillon Abotossaway
///@function   
///
///@description
///
///
///@return
function draw_player_health_bar(_self){
	// ----------------------
	//  🔴 DRAW PLAYER HEALTH BAR
	// ----------------------
	var max_health = _self.max_player_health; // Set max health (Adjust as needed)
	var bar_width = _self.width * _self.gem_size; // Full grid width
	var bar_height = 64; // Bar height
	var bar_x = _self.board_x_offset; // X Position
	var bar_y = -10; // Slightly above the grid

	// Calculate health percentage
	var health_percent = clamp(_self.player_health / max_health, 0, 1);
	var health_bar_width = bar_width * health_percent;

	// Draw background (gray full bar)
	draw_set_color(c_black);
	draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);

	// Draw actual health bar (Red)
	draw_set_color(c_red);
	draw_rectangle(bar_x, bar_y, bar_x + health_bar_width, bar_y + bar_height, false);

	// Draw Text (Health Number)
	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_text(bar_x + (bar_width / 2), bar_y + (bar_height / 2), "HP: " + string(_self.player_health) + "/" + string(max_health));

	// Reset Alignment
	draw_set_halign(fa_left);
}