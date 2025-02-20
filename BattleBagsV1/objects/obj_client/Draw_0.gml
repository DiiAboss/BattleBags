/// @desc Display Messages
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);

draw_text(x + 64, y + 100, string(obj_game_manager.input.ActionPress));

if (received_hosts)
{
    for (var i = 0; i < ds_list_size(hosts_list); i++)
    {
        var menu_y = menu_y_start + (i * menu_spacing);
        var host = ds_list_find_index(hosts_list, i);
        
        var str = string(i) + ": " + string(host);
        
        //draw_text(32, 32 + (32 * i), str);
        
        if (i == selected_option) {
            draw_set_color(c_white);
            draw_text(menu_x - 5, menu_y, "- " + string(host) + " -");
        } else {
            draw_set_color($29c8f0);
            draw_text(menu_x, menu_y, string(i) + ":" + string(host));
        }
    } 
}

if (connect_new_players)
{
    connect_new_players = false;
    alarm[3] = _FPS * 3;
    var data = ds_map_create();
    ds_map_add(data, "host_number", host_number)
    ds_map_add(data, "players", noone)
    send_map_over_UDP(self, data, DATA_TYPE.GET_NEW_PLAYERS, 200);
}