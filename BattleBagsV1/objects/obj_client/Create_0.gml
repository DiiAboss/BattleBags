/// @desc Connect to Server
client_socket = network_create_socket(network_socket_udp);
server_ip = "127.0.0.1";
server_port = 8080;

// ✅ Connect to the server
var connection = network_connect_raw(client_socket, server_ip, server_port);

if (connection >= 0) {
    show_message("Client connected to server!");
} else {
    show_message("Failed to connect to server!");
    instance_destroy();
}

message = "";
my_player_id = irandom_range(1, 255);





