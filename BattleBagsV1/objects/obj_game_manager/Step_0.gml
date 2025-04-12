

if keyboard_check_pressed(vk_shift) && !instance_exists(obj_event_start)
{
	instance_create_depth(x, y,depth, obj_event_start);
}


if (input_delay > 0)
{
    input_delay --;
}

//-----------------------------------------------
// CONSOLE STUFF
//-----------------------------------------------
#region console
if (keyboard_check_pressed(vk_f1)) { 
    //console_active = !console_active;
    generate_debug_upgrades();
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


if (room == rm_gameRoom)
{
    
     
    
    var t_distance  = point_distance(current_run.start_x, current_run.start_y, current_run.target_x, current_run.target_y);
    
    current_run.dir = point_direction(current_run.overworld_x, current_run.overworld_y, current_run.target_x, current_run.target_y)
    
    current_run.overworld_x += lengthdir_x(current_run.travel_speed, current_run.dir); 
    current_run.overworld_y += lengthdir_y(current_run.travel_speed, current_run.dir); 
    
    var distance_to_go = point_distance(current_run.overworld_x, current_run.overworld_y, current_run.target_x, current_run.target_y);
    
    
    var overspeed = current_run.travel_speed;
    

    
    
    
    if (keyboard_check_pressed(ord("M")))
    {
        room_set_persistent(rm_gameRoom, true);
        room_goto(rm_map_room_test);
    }
    
    
    if (time_left) <= 1 && event == false
    {
        add_priority_objective(0);
        event = true;
    }
    
    else {
    	
        time_left = distance_to_go / overspeed;
        
        var t_time    = t_distance / overspeed;
    
        show_debug_message("Time Left: " + string(time_left) + " / Total Time: " + string(t_time));
    }
    
}


if (room == rm_map_room_test)
{
    if (keyboard_check_pressed(ord("M")))
    {
        room_goto(rm_gameRoom);
    }
    
    
    camera_set_view_pos(view_get_camera(view_current), current_run.overworld_x-256, current_run.overworld_y-256)
}


