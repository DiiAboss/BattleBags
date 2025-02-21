///// @desc Client Async Network Event

show_debug_message(json_encode(async_load));

// Recieving Data
if (async_load[? "size"] > 0)
{
    var buff = async_load[? "buffer"];
    buffer_seek(buff, buffer_seek_start, 0);
    // Show response string from server
    var msg = buffer_read(buff, buffer_string);

    
    
    var json_resp = json_decode(msg);
    
    var data_type = ds_map_find_value(json_resp, "type");
    
    switch(data_type)
    {
        case DATA_TYPE.DEBUG:
            show_debug_message("data received");
        break;
        
        case DATA_TYPE.CREATE_HOST:
            show_debug_message("< " + msg);
            var host_number = ds_map_find_value(json_resp, "host_number");
            var player_number = ds_map_find_value(json_resp, "player_number");
            var is_host = ds_map_find_value(json_resp, "is_host");
        
            show_debug_message("HOST_NUMBER: " + string(host_number) + " | PLAYER_NUMBER: " + string(player_number));
            self.host_number = host_number;
            self.player_number = player_number;
            self.my_client = instance_create_layer(100, 100, "Instances", obj_client); // Replace with your player spawn code
            
            // ✅ Spawn player if this client is the host
            if (is_host) {
                show_debug_message("Spawning player as host...");
                with (my_client) {
                    self.my_player_id = player_number; // Assign player number
                    self.host_number = host_number;
                    self.player_number = player_number;
                    self.connected = true;
                    self.joined = true;
                }
            }
        
            room_goto(rm_online_lobby);
        
            
        break;
        
        case DATA_TYPE.STOP_HOST:
                    
             show_debug_message("< " + msg);
             var host_number   = ds_map_find_value(json_resp, "host_number");
             var res = ds_map_find_value(json_resp, "res");
             show_debug_message("HOST_NUMBER HAS STOPPED: " + string(host_number));
        
        if (res == "stopped")
        {
            is_host_stopped = true;
            with my_client
            {
                instance_destroy();
            }
            
            room_goto(rm_multiplayer_selection);
            instance_destroy();       
        }
            
        break;
        
        case DATA_TYPE.JOIN_HOST:
            show_debug_message("data received");
        break;
        
        case DATA_TYPE.START_GAME:
            show_debug_message("STARTING GAME");
            room_goto(rm_online_game);
        break;
        
        default:
            break;
    }
    
}