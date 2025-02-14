if (delay > 0)
{
    delay --;
}

else {
    var input = obj_game_manager.input;
    
    if (input_delay > 0)
    {
        input_delay--;
    }
    
    if (input.Left)
    {
        if (input_delay <= 0)
        {
            if selected <= 0
            {
                selected = array_size - 1;
            }
            else {
                selected --;
            }
            input_delay = max_input_delay;
        }
    }
    
    if (input.Right)
    {
        if (input_delay <= 0)
        {
           if selected >= array_size - 1
           {
               selected = 0;
           }
           else {
               selected ++;
           }
            input_delay = max_input_delay;
        }
    }
    
    
    if (!upgrade_pool[0])
    {
        global.all_stats_maxed = true;
    }
    
    
    // ✅ If no upgrades are available, do NOT open the menu
    if (global.all_stats_maxed) {
        //show_message("All upgrades have reached max level!");
        instance_destroy();
    }
    
    // ✅ Press 1, 2, or 3 to choose an upgrade via keyboard
    if (keyboard_check_pressed(ord("1"))) apply_upgrade(upgrade_pool[0]);
    if (keyboard_check_pressed(ord("2"))) apply_upgrade(upgrade_pool[1]);
    if (keyboard_check_pressed(ord("3"))) apply_upgrade(upgrade_pool[2]);
    
    // ✅ Check for mouse click on upgrades (Fixes click issue)
    if (input.ActionPress) {
        if (input.InputType = INPUT.KEYBOARD)
        {
            var mx = mouse_x;
            var my = mouse_y;
        
            for (var i = 0; i < array_size; i++) {
                var btn = global.upgrade_positions[i];
                // Adjust hitbox to account for hover animation size increase
            var hitbox_size = 128 * 1.1; // Hovered images scale up, so adjust hitbox
            if (mx >= btn.x - hitbox_size / 2 && mx <= btn.x + hitbox_size / 2 &&
                my >= btn.y - hitbox_size / 2 && my <= btn.y + hitbox_size / 2) {
                selected = i;
            }
        }
        }
        apply_upgrade(upgrade_pool[selected]);
        
        instance_destroy();
    }
}



