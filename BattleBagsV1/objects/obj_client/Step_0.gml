/// @desc Client Step Logic
var input = obj_game_manager.input;
input.Update(self, x, y);

ds_map_add(data, "x", mouse_x);
ds_map_add(data, "y", mouse_y);
ds_map_add(data, "id", id);
ds_map_add(data, "spr", sprite_index);

var data_json = json_encode(data);
ds_map_clear(data);

// 🔥 Send player input
if (input.ActionPress) {
    buffer_seek(client_buffer, buffer_seek_start, 0);
    buffer_write(client_buffer, buffer_text, data_json);
    network_send_udp_raw(client_socket, server_ip, server_port, client_buffer, buffer_tell(client_buffer));
    return;
}


