client_socket = network_create_socket(network_socket_udp);
server_ip = "127.0.0.1";
server_port = 7676;


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


client_buffer = buffer_create(100, buffer_fixed, 100);

//data = ds_map_create();

host_number = 0;
player_number = 0;
is_host_stopped = false;
should_host_stop = false;

host_started = false;
game_started = false;