function process_targetting_enemy(player, input, enemy_control, is_targeting_enemy)
{
    if !(is_targeting_enemy)
    {
        player.enemy_target = -1;
        return;
    }
    
    // Set the board targetting to false
    player.hover_x = -1;
    player.hover_y = -1;
    
    
    var total_enemies = enemy_control.amount_of_enemies;
    var enemy_found = false;
    
    if (input.InputType == INPUT.KEYBOARD)
    {
        player.enemy_target = keyboard_input(player, enemy_control);
    }
    
    if (input.InputType == INPUT.GAMEPAD)
    {
        player.enemy_target = gamepad_input(player, enemy_control);
    }
    
    
    if (enemy_target != -1)
    {
        if (input.ActionPress)
        {
            enemy_target.hp -= 1;
        }
    }
    
    static keyboard_input = function(player, enemy_control)
    {
        var half_gem_offset = player.gem_size * 0.5;
        var enemy_found = false;
        var target_enemy = -1;
        var total_enemies = enemy_control.amount_of_enemies;
        
        for (var _i = 0; _i < total_enemies; _i ++)
        {
            var enemy_pos_x1 = enemy_control.enemy_array[_i].x - half_gem_offset;
            var enemy_pos_x2 = enemy_control.enemy_array[_i].x + half_gem_offset;
            var enemy_pos_y1 = enemy_control.enemy_array[_i].y - half_gem_offset;
            var enemy_pos_y2 = enemy_control.enemy_array[_i].y + half_gem_offset;
            
            var mouse_hovering_enemy = (mouse_x > enemy_pos_x1  && mouse_x < enemy_pos_x2) 
                                    && (mouse_y > enemy_pos_y1  && mouse_y < enemy_pos_y2)
            
            
            if (mouse_hovering_enemy)
            {
                var current_enemy = enemy_control.enemy_array[_i];
                //player.enemy_target = current_enemy;
                target_enemy = current_enemy;
                enemy_found = true;
            }
        }
        
        return (target_enemy)    
    }
    
    static gamepad_input = function(player, enemy_control)
    {
        var target_enemy = -1;
        
        if (instance_exists(player.enemy_target))
        {
            var current_enemy = enemy_control.enemy_array[0];
            
            player.enemy_target = current_enemy;  
            target_enemy = current_enemy;
        }
        
        return target_enemy;
    }
}