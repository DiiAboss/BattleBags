function try_to_leave_host(client, host_number)
{
    if !(client.try_to_leave) return;
        
    if (client.left) return;
        
    var player_number = client.player_number;
    var data = ds_map_create();
    ds_map_add(data, "host_number", host_number);
    ds_map_add(data, "player_number", player_number);
    send_map_over_UDP(self, data, DATA_TYPE.LEAVE_HOST);
    
    client.try_to_leave = false;
    client.alarm[2] = _FPS * 2;
}

//if (try_to_leave && !left)
//{
    //try_to_leave = false;
    //alarm[2] = _FPS * 2;
    //
    //var data = ds_map_create();
    //ds_map_add(data, "host_number", host_number);
    //ds_map_add(data, "player_number", player_number);
    //send_map_over_UDP(self, data, DATA_TYPE.LEAVE_HOST);
//}