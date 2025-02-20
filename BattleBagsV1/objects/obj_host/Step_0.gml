/// @description
input = obj_game_manager.input;
input.Update(self, x, y);

if (input.Enter)
{
    show_debug_message("Host Started Game");
    var data = ds_map_create();
    
    ds_map_add(data, "host_number", noone);
    ds_map_add(data, "player_number", noone);
    
    
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