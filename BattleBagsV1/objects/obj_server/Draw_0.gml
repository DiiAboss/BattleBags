/// @desc Display Lobby Code & Waiting Players
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_basic);
draw_set_color(c_white);

// ✅ Draw Lobby Code
draw_text(room_width / 2, 50, "Lobby Code: " + server_lobby_code);

// ✅ Draw Connected Players
for (var i = 0; i < ds_map_size(global.connected_clients); i++) {
    var player = ds_map_find_value(global.connected_clients, i);
    draw_text(room_width / 2, 100 + (i * 40), "Player " + string(i + 1) + ": " + player.input_type);
}

// ✅ Draw Start Game Message
if (ds_map_size(global.connected_clients) > 0) {
    draw_text(room_width / 2, room_height - 50, "Press ENTER to Start Game");
}

