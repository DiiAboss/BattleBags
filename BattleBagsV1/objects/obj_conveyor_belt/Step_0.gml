/// @description Update Conveyor Movement

// Sync with global attack queue
queue_sync_timer++;
if (queue_sync_timer >= queue_sync_interval) {
    sync_with_global_queue();
    queue_sync_timer = 0;
}

// Move all attacks upward
for (var i = 0; i < ds_list_size(conveyor_attacks); i++) {
    var attack_data = conveyor_attacks[| i];
    
    // Move the attack upward
    attack_data.y_pos -= conveyor_speed;
    
    // Check if attack has reached activation position
    if (attack_data.y_pos <= conveyor_activation_y) {
        // Trigger attack execution in the game system
        trigger_attack_execution(attack_data.attack_name);
        
        // Remove from conveyor
        ds_list_delete(conveyor_attacks, i);
        i--; // Adjust the loop index
    }
}


/// @description Create Debug Menu
if (keyboard_check_pressed(vk_tab)) {
    debug_menu_open = !debug_menu_open;
}

// Draw debug menu when open
if (debug_menu_open) {
    draw_set_alpha(0.9);
    draw_rectangle_color(
        room_width - 220, 10,
        room_width - 10, 250,
        c_black, c_black, c_black, c_black, false
    );
    draw_set_alpha(1.0);
    
    draw_set_color(c_white);
    draw_text(room_width - 210, 20, "Attack Types:");
    
    var y_pos = 50;
    var attack_types = [
        "rectangle", "L_shape", "Z_shape", 
        "T_shape", "single_line", "FREEZE", 
        "SLIME", "BLOCK"
    ];
    
    for (var i = 0; i < array_length(attack_types); i++) {
        draw_text(room_width - 210, y_pos, string(i+1) + ": " + attack_types[i]);
        
        if (point_in_rectangle(mouse_x, mouse_y, 
                            room_width - 210, y_pos, 
                            room_width - 10, y_pos + 20) && 
            mouse_check_button_pressed(mb_left)) {
            
            add_specific_attack(attack_types[i]);
        }
        
        y_pos += 25;
    }
}


