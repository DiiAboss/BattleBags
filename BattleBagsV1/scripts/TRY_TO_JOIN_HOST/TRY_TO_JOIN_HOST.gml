function try_to_join_host(client, host_number)
{
    if (!client.try_to_join) return; 
        
    if (client.joined) return;
        
    var data = ds_map_create();
    ds_map_add(data, "host_number", host_number);
    ds_map_add(data, "player_number", noone);
    send_map_over_UDP(self, data, DATA_TYPE.JOIN_HOST);

    client.try_to_join = false;
    client.alarm[1] = _FPS * 2;
}

//if (try_to_join && !joined)
//{
    //try_to_join = false;
    //alarm[1] = _FPS * 2;
    //
    //var data = ds_map_create();
    //ds_map_add(data, "host_number", host_number);
    //ds_map_add(data, "player_number", noone);
    //send_map_over_UDP(self, data, DATA_TYPE.JOIN_HOST);
//}