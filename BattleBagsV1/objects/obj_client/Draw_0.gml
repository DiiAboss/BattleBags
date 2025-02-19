/// @desc Display Lobby Code & Waiting Players
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_basic);
draw_set_color(c_white);

// ✅ Draw Lobby Code
draw_text(room_width / 2, 50, "Lobby Code: " + global.lobby_code);

// ✅ Draw Waiting Players
for (var i = 0; i < ds_list_size(global.connected_players); i++) {
    var player = ds_list_find_value(global.connected_players, i);
    draw_text(room_width / 2, 100 + (i * 40), "Player " + string(i + 1) + ": " + player.inputType);
}

