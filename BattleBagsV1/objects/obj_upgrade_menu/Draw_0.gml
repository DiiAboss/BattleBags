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
    draw_text(draw_x, draw_y - 100, upgrade_data.name);

    // 📝 Upgrade Description (Below Frame)
    draw_text(draw_x, draw_y + 100, upgrade_data.desc);
}

// 🟢💣🔥 Show Spawn Rates & Game Speed Modifier
var info_x = room_width - 240;
var info_y = 140;
var line_spacing = 22;

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_text(info_x, info_y - 30, "📊 Upgrade Effects & Spawn Rates");

//draw_set_color(c_lime);
draw_text(info_x, info_y - 10, "🌟 Game Speed Modifier: " + string(global.gameSpeed));

// 🟥 🟨 🟩 🟦 🟪 Color Spawn Rates
draw_set_color(c_white);
draw_text(info_x, info_y, "🎨 Color Spawn Rates:");

var color_names = ["Red", "Yellow", "Green", "Blue", "Purple", "Orange"];
var color_keys = [BLOCK.RED, BLOCK.YELLOW, BLOCK.GREEN, BLOCK.PINK, BLOCK.PURPLE, BLOCK.ORANGE];

for (var i = 0; i < array_length(color_keys); i++) {
    var color_weight = global.color_spawn_weight[color_keys[i]];
    draw_text(info_x + 20, info_y + (i * line_spacing), color_names[i] + ": " + string(color_weight));
}

info_y += (array_length(color_keys) + 1) * line_spacing;

// 💣🏹🔥❄️⏳ Power-up Spawn Rates
draw_set_color(c_white);
draw_text(info_x, info_y, "💥 Power-up Spawn Rates:");

var powerup_names = ["Bomb", "Multi 2X", "Bow", "EXP", "Heart", "Money", "Fire", "Ice", "Timer", "Feather", "Wild Potion"];
var powerup_keys = [POWERUP.BOMB, POWERUP.MULTI_2X, POWERUP.BOW, POWERUP.EXP, POWERUP.HEART, POWERUP.MONEY, POWERUP.FIRE, POWERUP.ICE, POWERUP.TIMER, POWERUP.FEATHER, POWERUP.WILD_POTION];

for (var i = 0; i < array_length(powerup_keys); i++) {
    var powerup_weight = ds_map_find_value(global.powerup_weights, powerup_keys[i]);
    draw_text(info_x + 20, info_y + ((i + 1) * line_spacing), powerup_names[i] + ": " + string(powerup_weight));
}

