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
           var host_number   = ds_map_find_value(json_resp, "host_number");
           var player_number = ds_map_find_value(json_resp, "player_number");
           show_debug_message("HOST_NUMBER: " + string(host_number) + "|  PLAYER_NUMBER: " + string(player_number));
           self.host_number = host_number;
           self.player_number = player_number;
            room_goto(rm_online_game);
        
        
        break;
        
        case DATA_TYPE.STOP_HOST:
                    
             show_debug_message("< " + msg);
             var host_number   = ds_map_find_value(json_resp, "host_number");
             var res = ds_map_find_value(json_resp, "res");
             show_debug_message("HOST_NUMBER HAS STOPPED: " + string(host_number));
        
        if (res == "stopped")
        {
            is_host_stopped = true;
            room_goto(rm_multiplayer_selection);
            instance_destroy();       
        }
            
        break;
        
        case DATA_TYPE.JOIN_HOST:
            show_debug_message("data received");
        break;
        
        default:
            break;
    }
    
}