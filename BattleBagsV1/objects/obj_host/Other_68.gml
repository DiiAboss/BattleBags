/// @description

show_debug_message(json_encode(async_load));

// Recieving Data
if (async_load[? "size"] > 0)
{
    var buff = async_load[? "buffer"];
    buffer_seek(buff, buffer_seek_start, 0);
    // Show response string from server
    var response = buffer_read(buff, buffer_string);
    show_debug_message(response);
    
    resp_json = json_decode(response);
    
    x = ds_map_find_value(resp_json, "x");
    y = ds_map_find_value(resp_json, "y");
    sprite_index = ds_map_find_value(resp_json, "spr");
    //_id = ds_map_find_value(resp_json, "id");
}