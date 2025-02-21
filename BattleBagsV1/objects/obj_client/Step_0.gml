/// @desc Client Step Logic


connected = joined;
input = obj_game_manager.input;
input.Update(self, x, y);

if !(connected)
{
    if (room == rm_join_lobby)
    {
        // These process will only run when needed automatically
        try_and_receive_hosts(self); // try_to_get_hosts
        
        try_to_join_host(self, host_number); // try_to_join
        
        //----------------------------------------------------------
        // CLIENT LOBBY FUNCTIONS
        //----------------------------------------------------------
        if (received_hosts)
        {
            var mouse_x_pos = device_mouse_x(0);
            var mouse_y_pos = device_mouse_y(0);
            var list_size = ds_list_size(hosts_list);
            menu_y_start = room_height / 2 - (menu_spacing * (list_size / 2));
            
            y = menu_y_start + (selected_option * menu_spacing);
            
            // ✅ Mouse hover detection
            for (var i = 0; i < list_size; i++) {
                var menu_y = menu_y_start + (i * menu_spacing);
                
                if (point_in_rectangle(mouse_x_pos, mouse_y_pos, menu_x - 100, menu_y - 20, menu_x + 100, menu_y + 20)) {
                    selected_option = i;
                    last_hovered_option = i; // Store the last hovered item
                }
            }
            if (input_delay > 0)
                {
                    input_delay--;
                }
                
                if (input.Up)
                {
                    if (input_delay <= 0)
                    {
                        selected_option = (selected_option - 1 + list_size) mod list_size;
                        last_hovered_option = selected_option; // Reset hover when using keys
                        input_delay = max_input_delay;
                    }
                }
                
                if (input.Down)
                {
                    if (input_delay <= 0)
                    {
                        selected_option = (selected_option + 1) mod list_size;
                        last_hovered_option = selected_option;
                        input_delay = max_input_delay;
                    }
                }
            
            
            // ✅ Handle menu selection (keyboard OR mouse click)
            if (input.ActionPress || input.Enter) {
                if (last_hovered_option == -1 || last_hovered_option == selected_option) {
                    //CONNECT TO THE SELECTED HOST! SO CLOSE!!
                    host_number = last_hovered_option;
                    try_to_join = true;
                }
            }
        }
    }

}


// ✅ Handle menu selection (keyboard OR mouse click)
if (keyboard_check_pressed(vk_escape)) {
        try_to_leave = true;
}
try_to_leave_host(self, host_number); // try_to_leave


if (connect_new_players)
{
    connect_new_players = false;
    alarm[3] = _FPS * 3;
    var data = ds_map_create();
    ds_map_add(data, "host_number", host_number)
    ds_map_add(data, "players", noone)
    send_map_over_UDP(self, data, DATA_TYPE.GET_NEW_PLAYERS, 200);
}



if (player_controlled)
{
    input = obj_game_manager.input;
    input.Update(self, x, y);
    set_stats_online(self, input);
    
}
else {
    input = online_input;
    get_stats_online(self, online_input);
}



function set_stats_online(player, input)
{
    _x = mouse_x;
    _y = mouse_y;
    
    
    var data = ds_map_create();
    ds_map_add(data, "x", _x);
    ds_map_add(data, "y", _y);
    ds_map_add(data, "action_key",  input.ActionPress);
    ds_map_add(data, "left_key",    input.Left);
    ds_map_add(data, "up_key",     input.Up);
    ds_map_add(data, "down_key",   input.Down);
    ds_map_add(data, "right_key",   input.Right);
    ds_map_add(data, "host_number",    player.host_number);
    ds_map_add(data, "player_number",  player.player_number);
    
    send_map_over_UDP(player, data, DATA_TYPE.SEND_PLAYER_STATS, 1000);
}

function get_stats_online(player, input)
{
    var data = ds_map_create();
    ds_map_add(data, "host_number",    player.host_number);
    ds_map_add(data, "player_number",  player.player_number);
    ds_map_add(data, "player_stats",   noone);
    
    send_map_over_UDP(player, data, DATA_TYPE.GET_PLAYER_STATS, 300);
}