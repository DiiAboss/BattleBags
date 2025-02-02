// 🎨 Draw background box
draw_set_color(c_black);
draw_rectangle(100, 100, room_width - 100, room_height - 100, false);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(room_width / 2, 80, "Choose an Upgrade");

// 🖱️ Mouse Hover Detection & Selection Logic
var hover_index = -1;
var mouse_x_pos = mouse_x;
var mouse_y_pos = mouse_y;

// ✅ Detect mouse hovering over upgrades
for (var i = 0; i < array_size; i++) {
    var btn = global.upgrade_positions[i];

    if (mouse_x_pos > btn.x - 128 && mouse_x_pos < btn.x + 128 &&
        mouse_y_pos > btn.y - 128 && mouse_y_pos < btn.y + 128) {
        hover_index = i;
    }
}

// ✅ Draw Upgrade Frames with Hover Effect
for (var i = 0; i < array_size; i++) {
    var btn = global.upgrade_positions[i];
    var upgrade_data = upgrade[i];

    // 🔥 Base Scaling & Rotation
    var scale = 1.0;
    var rotation = 0;

    // 🔥 Apply hover effect
    if (i == hover_index) {
        scale = 1.1; // Slightly enlarged
        rotation = sin(degtorad(current_time * 2)) * 5; // Oscillates slightly (-5° to +5°)
    }

    // ✅ Fix Center Origin Issue: Adjust Draw Position
    var draw_x = btn.x;
    var draw_y = btn.y;

    // 🖼️ Draw upgrade frame with animation (now using correct centering)
    draw_sprite_ext(spr_upgrade_frame, upgrade_data.level, draw_x, draw_y, scale, scale, rotation, c_white, 1);

    // 🔠 Upgrade Name (Above Frame)
    draw_set_halign(fa_center);
    draw_text(draw_x, draw_y - 80, upgrade_data.name);
	// 📝 Display upgrade descriptions centered **below all upgrades**
	var desc_y_position = 500;
	draw_set_alpha(0.5);
	draw_text(global.upgrade_positions[i].x, desc_y_position, upgrade[i].desc);
	draw_set_alpha(1);
    // 📝 Display affected block or powerup sprite next to the frame
    var sprite_to_draw = get_upgrade_sprite(upgrade_data.effect);
    draw_sprite(sprite_to_draw, 0, draw_x, draw_y); // Positioned next to upgrade frame
}

if (hover_index != -1)
{
// 📝 Display upgrade descriptions centered **below all upgrades**
var desc_y_position = 500;
draw_set_halign(fa_center);
draw_text(global.upgrade_positions[hover_index].x, desc_y_position, upgrade[hover_index].desc);
}

