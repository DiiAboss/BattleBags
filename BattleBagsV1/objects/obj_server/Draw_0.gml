/// @desc Display Lobby Code & Waiting Players
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);

// ✅ Draw Lobby Code
draw_text(room_width / 2, 50, "Server Port: " + string(server_port));

// ✅ Draw Connected Players
for (var i = 0; i < ds_list_size(global.connected_clients); i++) {
    draw_text(room_width / 2, 100 + (i * 40), "Player " + string(i + 1) + " Connected");
}

// ✅ Draw Message
draw_text(x + 64, y + 100, string(message));
