// 🎨 Draw background box
draw_set_color(c_black);
draw_set_alpha(0.95);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(room_width / 2, draw_y_start + 80, "Choose an Upgrade");

// ️ Mouse Hover Detection & Selection Logic
var hover_index = -1;
var mouse_x_pos = mouse_x;
var mouse_y_pos = mouse_y;

//  Detect mouse hovering over upgrades
for (var i = 0; i < array_length(upgrade_pool); i++) {
    var btn = global.upgrade_positions[i];

    if (mouse_x_pos > btn.x - 128 && mouse_x_pos < btn.x + 128 &&
        mouse_y_pos > btn.y - 128 && mouse_y_pos < btn.y + 128) {
        hover_index = i;
    }
}

// ✅ Draw Upgrade Frames with Hover Effect
for (var i = 0; i < array_length(upgrade_pool); i++) {
    var btn = global.upgrade_positions[i];
	
	if (upgrade_pool[i])
	{	
	    var upgrade_data = upgrade_pool[i];
		
		    //  Base Scaling & Rotation
		    var scale = 1.0;
		    var rotation = 0;

		    //  Apply hover effect
		    if (i == hover_index) {
		        scale = 1.1; // Slightly enlarged
		        rotation = sin(degtorad(current_time * 2)) * 5; // Oscillates slightly (-5° to +5°)
		    }

		    // ✅ Fix Center Origin Issue: Adjust Draw Position
		    var draw_x = btn.x;
		    var draw_y = btn.y;

		    //  Draw upgrade frame with animation (now using correct centering)
		    draw_sprite_ext(spr_upgrade_frame, upgrade_pool[i].level, draw_x, draw_y, scale, scale, rotation, c_white, 1);

		    //  Upgrade Name (Above Frame)
		    draw_set_halign(fa_center);
		    draw_text(draw_x, draw_y - 80, upgrade_data.name);
			//  Display upgrade descriptions centered **below all upgrades**
			var desc_y_position = 500 + draw_y_start;
			draw_set_alpha(0.5);
			draw_text(global.upgrade_positions[i].x, desc_y_position, upgrade_pool[i].desc);
			draw_set_alpha(1);
		    //  Display affected block or powerup sprite next to the frame
		    var sprite_to_draw = get_upgrade_sprite(upgrade_data.effect);
		    draw_sprite(sprite_to_draw, 0, draw_x, draw_y); // Positioned next to upgrade frame
	}
}

if (hover_index != -1) && (upgrade_pool[hover_index])
{
	//  Display upgrade descriptions centered **below all upgrades**
	var desc_y_position = 500 + draw_y_start;
	draw_set_halign(fa_center);
	draw_text(global.upgrade_positions[hover_index].x, desc_y_position, upgrade_pool[hover_index].desc);

// 🔢 Display **Current Stat Value**
    var stat_value = get_upgrade_current_stat(upgrade_pool[hover_index].effect);
    draw_set_color(c_lime);
    draw_text(global.upgrade_positions[hover_index].x, desc_y_position + 20, "Current Value: " + string(stat_value));
}

// ------------------------------------
// 🎨 Display Gem Spawn Rates (LEFT SIDE)
// ------------------------------------
var gem_x = (room_width / 2) - 178;  // Left Position
var gem_y = room_height / 1.75 + draw_y_start;
var gem_line_spacing = 22;

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_text(gem_x, gem_y - 20, "🎨 Gem Spawn Rates:");

var gem_percentages = get_color_spawn_percentages(self);
var gem_names = [   "Red",     "Yellow",     "Green",     "Lightblue",     "Purple",     "Orange",     "Pink",     "Blue"];
var gem_keys = [BLOCK.RED, BLOCK.YELLOW, BLOCK.GREEN, BLOCK.LIGHTBLUE, BLOCK.PURPLE, BLOCK.ORANGE, BLOCK.PINK, BLOCK.BLUE];

for (var i = 0; i < array_length(gem_keys); i++) {
    var gem_percentage = gem_percentages[gem_keys[i]];
    draw_text(gem_x, gem_y + (i * gem_line_spacing), gem_names[i] + ": " + string(round(gem_percentage)) + "%");
}


// --------------------------------------
// 💥 Display Power-Up Spawn Rates (RIGHT SIDE)
// --------------------------------------
var powerup_x = (room_width / 2) + 64;  // Right Position
var powerup_y = room_height / 1.75 + draw_y_start;
var powerup_line_spacing = 22;

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_text(powerup_x, powerup_y - 20, "💥 Power-Up Spawn Rates:");

var powerup_names = ["Bomb", "Multi 2X", "Bow", "EXP", "Heart", "Money", "Fire", "Ice", "Timer", "Feather", "Wild Potion"];
var powerup_keys = [POWERUP.BOMB, POWERUP.MULTI_2X, POWERUP.BOW, POWERUP.EXP, POWERUP.HEART, POWERUP.MONEY, POWERUP.FIRE, POWERUP.ICE, POWERUP.TIMER, POWERUP.FEATHER, POWERUP.WILD_POTION];

for (var i = 0; i < array_length(powerup_keys); i++) {
    var powerup_weight = ds_map_find_value(global.powerup_weights, powerup_keys[i]);
    draw_text(powerup_x, powerup_y + (i * powerup_line_spacing), powerup_names[i] + ": " + string(powerup_weight) + "%");
}

