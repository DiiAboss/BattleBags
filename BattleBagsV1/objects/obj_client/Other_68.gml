///// @desc Client Async Network Event

//show_debug_message(json_encode(async_load));

// Recieving Data
if (async_load[? "size"] > 0)
{
    var buff = async_load[? "buffer"];
    buffer_seek(buff, buffer_seek_start, 0);
    // Show response string from server
    var msg = buffer_read(buff, buffer_string);

    //show_debug_message("< " + msg);
    
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
            show_debug_message("PLAYER NUMBER: " + string(player_number) + " JOINED " + string(host_number));
            joined = true;
            connected = true;
        break; 
        
        case DATA_TYPE.LEAVE_HOST:
                            
            show_debug_message("leaving host");
            show_debug_message("PLAYER NUMBER: " + string(player_number) + " LEFT " + string(host_number));
            host_number = -1;
            room_goto(rm_multiplayer_selection);
            instance_destroy();
                            
        break;  
        
        case DATA_TYPE.START_GAME:
                            
            show_debug_message("leaving host");
            game_started  = ds_map_find_value(json_resp, "game_started");
            host_number   = ds_map_find_value(json_resp, "host_number");
            show_debug_message("GAME STARTED AT: " + string(host_number));
            
          show_debug_message("STARTING GAME");
          room_goto(rm_online_game);
                            
        break;     
      
        case DATA_TYPE.SEND_PLAYER_STATS:
                            

                            
        break; 
        
        case DATA_TYPE.GET_PLAYER_STATS:
        
        var player_stats = ds_map_find_value(json_resp, "player_stats");
        var up = false;
        var left = false;
        var down = false;
        var right = false;
        var action_key = false;  
        var pn = ds_map_find_value(json_resp, "player_number");
        if  (pn == player_number)
        {
            up = ds_map_find_value(player_stats, "up_key");
            left = ds_map_find_value(player_stats, "left_key");
            down = ds_map_find_value(player_stats, "down_key");
            right = ds_map_find_value(player_stats, "right_key");
            action_key = ds_map_find_value(player_stats, "action_key");
            x = ds_map_find_value(player_stats, "x");
            y = ds_map_find_value(player_stats, "y");
            
            online_input.Update(up, left, down, right, action_key, -1, -1);
        }
        else {
            player_controlled = true;
        }
        
        show_debug_message("LEFT: " + string(left));
        show_debug_message("UP: " + string(up));
        show_debug_message("DOWN: " + string(down));
        show_debug_message("RIGHT: " + string(right));
        show_debug_message("x: " + string(x));
        show_debug_message("y: " + string(y));
        break;   
        
        case DATA_TYPE.GET_NEW_PLAYERS:
                
            var players = ds_map_find_value(json_resp, "players");
                                
            show_debug_message("PLAYERS: " + string(players));
                                
            break;     
  
        default: 
            
        break;
    }
}



