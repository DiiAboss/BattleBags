if (input_delay > 0)
{
    input_delay --;
}

//-----------------------------------------------
// CONSOLE STUFF
//-----------------------------------------------
#region console
if (keyboard_check_pressed(vk_f1)) { 
    console_active = !console_active;
}

process_console(self, console_active);
#endregion


if room == rm_main_menu
{
    var gp_num = gamepad_get_device_count();
    for (var i = 0; i < gp_num; i++;)
    {
        if (gamepad_is_connected(i))
        {
            if gamepad_button_check(i, gp_start)
            {
                input.Device = i;
                input.InputType = INPUT.GAMEPAD;
            }
        }
    } 
}



if (room == rm_create_lobby)
{
    if !(instance_exists(obj_host))
    {
        instance_create_depth(x, y, depth, obj_host);
    }
}

if (room == rm_join_lobby)
{
    if !(instance_exists(obj_client))
    {
        instance_create_depth(x, y, depth, obj_client)
    }
}

if (room == rm_online_multiplayer_menu)
{
    if (instance_exists(obj_client))
    {
        with (obj_client)
        {
            instance_destroy();
        }
    }
    
    if (instance_exists(obj_host))
    {
        with (obj_host)
        {
            instance_destroy();
        }
    }
}


