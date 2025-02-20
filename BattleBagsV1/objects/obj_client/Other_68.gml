///// @desc Client Async Network Event

show_debug_message(json_encode(async_load));

// Recieving Data
if (async_load[? "size"] > 0)
{
    var buff = async_load[? "buffer"];
    buffer_seek(buff, buffer_seek_start, 0);
    // Show response string from server
    var msg = buffer_read(buff, buffer_string);

    show_debug_message("< " + msg);
    
    var json_resp = json_decode(msg);
    
    var data_type = ds_map_find_value(json_resp, "type");
    
    switch(data_type)
    {
        case DATA_TYPE.DEBUG:
            show_debug_message("data received");
        break;
        
        case DATA_TYPE.CREATE_HOST:
            show_debug_message("data received");
        break;
        
         case DATA_TYPE.GET_HOSTS:
            
            show_debug_message("getting hosts");
            var hosts = ds_map_find_value(json_resp, "hosts");
            show_debug_message(hosts);
            hosts_list = hosts;
            received_hosts = true;
            
        
        break;
        
        case DATA_TYPE.JOIN_HOST:
                    
            show_debug_message("joining host");
            player_number = ds_map_find_value(json_resp, "player_number");
            host_number   = ds_map_find_value(json_resp, "host_number");
            show_debug_message("PLAYER NUMBER: " + string(player_number) + "JOINED " + string(host_number));
            joined = true;
        break; 
        
        case DATA_TYPE.LEAVE_HOST:
                            
            show_debug_message("leaving host");
            player_number = ds_map_find_value(json_resp, "player_number");
            host_number   = 0;
            show_debug_message("PLAYER NUMBER: " + string(player_number) + "LEFT " + string(host_number));
            
            room_goto(rm_multiplayer_selection);
            instance_destroy();
                            
        break;     
        
        default:
            break;
    }
}



