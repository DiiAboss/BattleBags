/// @description
input = obj_game_manager.input;
input.Update(self, x, y);

if (input.Enter)
{
    if (!host_started)
    {
        show_debug_message("Host Created Lobby");
        var data = ds_map_create();
        
        ds_map_add(data, "host_number", noone);
        ds_map_add(data, "player_number", noone);
        
        
        send_map_over_UDP(self, data, DATA_TYPE.CREATE_HOST);
        //host_started = true;
    }
    
    }

if (input.Back) {
        show_debug_message("Host Started Game");
        var data = ds_map_create();
        
        ds_map_add(data, "host_number", host_number);
        ds_map_add(data, "game_started", game_started);
        
        
        send_map_over_UDP(self, data, DATA_TYPE.CREATE_HOST);    
    }




if (input.Escape)
{
    should_host_stop = true;
}


if (should_host_stop && !is_host_stopped)
{
    should_host_stop = false;
    show_debug_message("Host Ended Game");
    var data = ds_map_create();
    
    ds_map_add(data, "host_number", host_number);
    ds_map_add(data, "res", noone);
    
    
    send_map_over_UDP(self, data, DATA_TYPE.STOP_HOST);
    alarm[0] = _FPS * 2;
}

if (connect_new_players)
{
    connect_new_players = false;
    alarm[1] = _FPS * 3;
    var data = ds_map_create();
    ds_map_add(data, "host_number", host_number)
    ds_map_add(data, "players", noone)
    send_map_over_UDP(self, data, DATA_TYPE.GET_NEW_PLAYERS, 200);
}