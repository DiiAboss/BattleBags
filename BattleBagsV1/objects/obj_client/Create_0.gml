/// @desc Connect to Server and Create/Join Lobby

global.hosting = false;
global.connected_players = ds_list_create();
client_socket = network_create_socket(network_socket_udp);
server_ip = "127.0.0.1";
server_port = 6500;

// ✅ Generate or enter lobby code
if (global.hosting) {
    global.lobby_code = generate_lobby_code();
} else {
    global.lobby_code = get_string("Enter Lobby Code:", ""); // Prompt player
}

// ✅ Send "join" request to server
var buffer = buffer_create(256, buffer_fixed, 1);
buffer_write(buffer, buffer_string, "join " + global.lobby_code);
network_send_udp(client_socket, server_ip, server_port, buffer, buffer_tell(buffer));
buffer_delete(buffer);

my_player_id = generate_lobby_code();


