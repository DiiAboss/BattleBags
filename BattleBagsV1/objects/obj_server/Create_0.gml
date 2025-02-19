/// @desc Initialize Server
/// 
server_port = 6500;
server_socket = network_create_server(network_socket_udp, server_port, 4);

server_lobby_code = generate_lobby_code(); // Generates a unique lobby code

// ✅ Initialize global data
global.connected_clients = ds_map_create(); // Stores connected players
global.game_state = ds_list_create(); // Stores player states
global.lobbies = ds_map_create(); // Stores active lobbies

// ✅ Register the new lobby
ds_map_add(global.lobbies, server_lobby_code, server_port);

show_message("Server started! Lobby Code: " + server_lobby_code);

