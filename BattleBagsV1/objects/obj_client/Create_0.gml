/// @desc Connect to Server
network_set_config(network_config_connect_timeout, 1000);
//network_set_config(network_config_use_non_blocking_socket, 1);

client_socket = network_create_socket(network_socket_udp);
server_ip = "127.0.0.1";
server_port = 7676;

// ✅ Connect to the server
var connection = network_connect(client_socket, server_ip, server_port);

if (connection >= 0) {
    show_message("Client connected to server!");
} else {
    show_message("Failed to connect to server!");
    instance_destroy();
}

message = "";
my_player_id = irandom_range(1, 255);
