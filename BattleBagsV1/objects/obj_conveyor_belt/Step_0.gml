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