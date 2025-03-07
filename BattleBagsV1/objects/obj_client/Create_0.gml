/// @desc Connect to Server
client_socket = network_create_socket(network_socket_udp);
server_ip = "127.0.0.1";
server_port = 7676;


not_host_controlled = false;
alarm[9] = 1;

message = "";
my_player_id = irandom_range(1, 255);


player_controlled = false;


hosts_list = ds_list_create();



selected_option = 0;
last_hovered_option = -1; // -1 means no hover yet
menu_spacing = 72; // Spacing between menu items
menu_x = room_width / 2;
menu_y_start = room_height / 2 - (menu_spacing * (ds_list_size(hosts_list) / 2));

input_delay = 0;
max_input_delay = 10;

host_number = 0;
player_number = 0;

received_hosts = false;
try_to_get_hosts = true;

try_to_join = false;
joined = false;

try_to_leave = false;
left = false;

game_started = false;

input = noone;
online_input = new Online_Input();

connected = false;
connect_new_players = true;

// Add to obj_client/Create_0.gml
// New variables for enhanced server features
last_heartbeat_time = current_time;
heartbeat_interval = 3000; // 3 seconds
connection_id = ""; // Will store our unique client identifier
lobby_id = ""; // For the new lobby system
is_in_matchmaking = false;

// Add these variables
lobby_id = "";
is_in_ranked_match = false;
player_rating = 1200;