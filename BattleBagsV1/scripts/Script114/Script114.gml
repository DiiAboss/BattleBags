/// @function spawn_attack_on_conveyor
/// @description Creates a new attack with more control over types
function spawn_attack_on_conveyor() {
    var attack_pattern;
    var is_special = false;
    var current_difficulty = min(10, max(1, obj_game_control.level / 3));
    
    // More special attacks at higher difficulty
    var special_chance = 0.1 + (current_difficulty * 0.02); // 10% base + 2% per difficulty level
    
    if (random(1) < special_chance && array_length(global.shape_templates) > 0) {
        // Choose a special attack
        var pattern_index = irandom(array_length(global.shape_templates) - 1);
        attack_pattern = global.shape_templates[pattern_index];
        is_special = true;
    } else {
        // Choose a shape type based on difficulty
        var shape_options = ["rectangle", "single_line"]; // Basic shapes for early game
        
        if (current_difficulty >= 3) {
            array_push(shape_options, "L_shape"); // Add L shapes at difficulty 3+
        }
        
        if (current_difficulty >= 5) {
            array_push(shape_options, "T_shape"); // Add T shapes at difficulty 5+
        }
        
        if (current_difficulty >= 7) {
            array_push(shape_options, "Z_shape"); // Add Z shapes at difficulty 7+
        }
        
        var shape_type = shape_options[irandom(array_length(shape_options) - 1)];
        var attack_power = 1 + floor(current_difficulty / 2); // Scale attack power with difficulty
        
        attack_pattern = generate_attack_shape(attack_power, obj_game_control, shape_type);
    }
    
    // Create the attack data structure
    var attack_data = {
        attack_name: attack_pattern,
        is_special: is_special,
        y_pos: conveyor_start_y,
        lane: irandom(lane_count - 1),  // Random lane placement
        preview_data: ds_map_find_value(attack_preview_cache, attack_pattern),
        speed_modifier: random_range(0.8, 1.2)  // Slight speed variations
    };
    
    // Add to conveyor
    ds_list_add(conveyor_attacks, attack_data);
    
    return attack_data;
}