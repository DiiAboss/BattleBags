/// @desc Process Incoming Network Data
var _id = async_load[? "id"];
if (_id != server_socket) exit; // Ignore unrelated sockets

var client_ip = async_load[? "ip"];
var client_port = async_load[? "port"];
var data = buffer_read(async_load[? "buffer"], buffer_string);
var parts = string_split(data, " ");
var command = parts[0];

/// 🔹 **Player Joins the Lobby**
if (command == "join") {
    var lobby_code = parts[1];

    if (ds_map_exists(global.lobbies, lobby_code)) {
        var _player_id = ds_list_size(global.game_state);
        
        // ✅ Add player to the game state
        var player = {
            id: _player_id,
            ip: client_ip,
            port: client_port,
            input_type: "NONE",
            grid: create_grid_array(),
            global_y_offset: 0,
            shift_speed: 1,
            hovered_block: [4, 12], // Default selection
            pop_list: ds_list_create(),
        };
        
        ds_list_add(global.game_state, player);
        ds_map_add(global.connected_clients, _player_id, player);

        // ✅ Send Player ID & Confirmation
        var buffer = buffer_create(256, buffer_fixed, 1);
        buffer_write(buffer, buffer_string, "connect " + string(server_port) + " " + string(_player_id));
        network_send_udp(server_socket, client_ip, client_port, buffer, buffer_tell(buffer));
        buffer_delete(buffer);
    }
}

/// 🔹 **Assign Player Input Type**
if (command == "set_input") {
    var _player_id = real(parts[1]);
    var input_type = parts[2];

    if (ds_map_exists(global.connected_clients, _player_id)) {
        var player = ds_map_find_value(global.connected_clients, _player_id);
        player.input_type = input_type;
        ds_map_replace(global.connected_clients, _player_id, player);
    }
}

/// 🔹 **Handle Player Inputs (Swaps, Moves)**
if (command == "input") {
    var _player_id = real(parts[1]);
    var action_key = real(parts[2]);
    var target_x = real(parts[3]);
    var target_y = real(parts[4]);

    if (ds_map_exists(global.connected_clients, _player_id)) {
        var player = ds_map_find_value(global.connected_clients, _player_id);
        start_swap(player, target_x, target_y, target_x + 1, target_y);
    }
}

/// 🔹 **Sync game state with all players**
for (var i = 0; i < ds_list_size(global.game_state); i++) {
    var player = ds_list_find_value(global.game_state, i);

    var buffer = buffer_create(256, buffer_fixed, 1);
    buffer_write(buffer, buffer_string, "sync " + string(i) + " " + string(player.global_y_offset));
    network_send_udp(server_socket, player.ip, player.port, buffer, buffer_tell(buffer));
    buffer_delete(buffer);
}


