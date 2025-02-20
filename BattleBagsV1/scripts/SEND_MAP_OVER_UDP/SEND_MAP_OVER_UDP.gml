function send_map_over_UDP(sender, data_map, data_type, size = 100)
{
    var ip     = sender.server_ip;
    var port   = sender.server_port;
    var client = sender.client_socket;
    
    network_connect_raw(client, ip, port);
    var buffer = buffer_create(size, buffer_fixed, size);
    
    ds_map_add(data_map, "type", data_type)
    var data_json = json_encode(data_map);
    show_debug_message("> " + string(data_json));
    ds_map_destroy(data_map);
    
    buffer_seek(client, buffer_seek_start, 0);
    buffer_write(client, buffer_text, data_json);
    network_send_udp_raw(client, ip, port, client, buffer_tell(client));
}