/// @description

//show_debug_message(json_encode(async_load));

// Recieving Data
if (async_load[? "size"] > 0)
{
    var buff = async_load[? "buffer"];
    buffer_seek(buff, buffer_seek_start, 0);
    // Show response string from server
    var response = buffer_read(buff, buffer_string);
    //show_debug_message(response);
    buffer_delete(buff);
    var resp_json = json_decode(response);
    
    var _x = ds_map_find_value(resp_json, "x");
    var _y = ds_map_find_value(resp_json, "y");
    var _spr = ds_map_find_value(resp_json, "spr");
    sprite_index = _spr;
    x = _x;
    y = _y;
    show_debug_message("X: " + string(_x));
    show_debug_message("Y: " + string(_y));
    show_debug_message("SPR: " + string(_spr));
    //_id = ds_map_find_value(resp_json, "id");
}