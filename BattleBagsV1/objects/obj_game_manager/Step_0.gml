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


if room != rm_local_multiplayer_lobby
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



if (room == rm_local_multiplayer_lobby)
{
    if !(instance_exists(obj_local_multiplayer_control))
    {
        instance_create_depth(depth-1, x, y, obj_local_multiplayer_control);
    }
}