/// @desc Client Step Logic
var input = obj_game_manager.input;

// 🔥 Send player input
if (input.ActionKey) {
    var buffer = buffer_create(256, buffer_grow, 1);
    buffer_seek(buffer, buffer_seek_start, 0);
    buffer_write(buffer, buffer_u16, 1); // CMD: Input
    buffer_write(buffer, buffer_u8, my_player_id);
    buffer_write(buffer, buffer_u8, input.ActionKey);
    network_send_packet(client_socket, buffer, buffer_tell(buffer));
    buffer_delete(buffer);
}


