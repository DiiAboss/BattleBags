/// @desc Client Step Logic
var input = obj_game_manager.input;
input.Update(self, x, y);
x = mouse_x;
y = mouse_y;





if (!received_hosts && try_to_get_hosts)
{
    try_to_get_hosts = false;
    alarm[0] = _FPS * 2;
    
    var data = ds_map_create();
    ds_map_add(data, "hosts", noone);
    send_map_over_UDP(self, data, DATA_TYPE.GET_HOSTS);
    
}



// 🔥 Send player input
if (input.ActionPress) {

    var data = ds_map_create();
    // The Data To Send To Server
    ds_map_add(data, "x", mouse_x);
    ds_map_add(data, "y", mouse_y);
    ds_map_add(data, "id", id);
    ds_map_add(data, "spr", sprite_index);
    
    send_map_over_UDP(self, data, DATA_TYPE.DEBUG);

}

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
                last_hovered_option = -1; // Reset hover when using keys
                input_delay = max_input_delay;
            }
        }
        
        if (input.Down)
        {
            if (input_delay <= 0)
            {
                selected_option = (selected_option + 1) mod list_size;
                last_hovered_option = -1;
                input_delay = max_input_delay;
            }
        }
    
    
    // ✅ Handle menu selection (keyboard OR mouse click)
    if (input.ActionPress || input.Enter) {
        if (last_hovered_option == -1 || last_hovered_option == selected_option) {
            //CONNECT TO THE SELECTED HOST! SO CLOSE!!
        }
    }
    
}


