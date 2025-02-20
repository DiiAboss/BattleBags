function try_and_receive_hosts(client)
{
    if (!client.try_to_get_hosts) return;
    if (client.received_hosts) return;
        
    var data = ds_map_create();
    ds_map_add(data, "hosts", noone);
    send_map_over_UDP(self, data, DATA_TYPE.GET_HOSTS);
    
    client.alarm[0] = _FPS * 2;
    client.try_to_get_hosts = false;
}
//if (!received_hosts && try_to_get_hosts)
//{
    //try_to_get_hosts = false;
    //alarm[0] = _FPS * 2;
    //
    //var data = ds_map_create();
    //ds_map_add(data, "hosts", noone);
    //send_map_over_UDP(self, data, DATA_TYPE.GET_HOSTS);
    //
//}