

/// @description Generates a basic attack and adds it to the queue.
function enemy_attack_basic(_self, game_control_object) {
    var attack_pattern = generate_attack_shape(_self.attack_power, game_control_object);

    // 🔥 Add attack to queue **for preview & execution**
    ds_list_add(global.enemy_attack_queue, attack_pattern);

    return attack_pattern;
}


/// @function enemy_attack_special
/// @description Adds a special attack to the queue.
function enemy_attack_special(_self, attack_pattern) {
    ds_list_add(global.enemy_attack_queue, attack_pattern);
}

///// @description Generates a random attack shape dynamically.
//function generate_attack_shape(_attack, game_control_object) {
    //var max_width = obj_game_control.width;
    //var max_height = 4; // Max row limit to prevent soft-locks
//
    //var shape_width = irandom_range(1, min(_attack, max_width));
    //var shape_height = irandom_range(1, min(_attack div max_width + 1, max_height));
//
    //var game_level = game_control_object.level;
    //var block_to_drop = (game_level > 10) ? BLOCK.BLACK : BLOCK.RANDOM;
//
    //// ✅ Prevent the 4th row from forming until previous rows are filled
    //if (_attack >= (max_width * 3) && shape_height <= 4) {
        //shape_height = 3;
    //}
//
    //var attack_template = array_create(shape_height);
    //var remaining_blocks = _attack;
//
    //for (var _y = 0; _y < shape_height; _y++) {
        //attack_template[_y] = array_create(shape_width, BLOCK.NONE);
//
        //for (var _x = 0; _x < shape_width; _x++) {
            //if (remaining_blocks > 0) {
                //attack_template[_y][_x] = block_to_drop;
                //remaining_blocks--;
            //}
        //}
//
        //// ✅ Add L-Shape or gap randomness
        //if (remaining_blocks > 0 && irandom(3) == 0) {
            //attack_template[_y][irandom(shape_width - 1)] = BLOCK.NONE;
            //remaining_blocks++;
        //}
    //}
//
    //var attack_name = "dynamic_" + string(_attack) + "_" + string(irandom(9999));
    //ds_map_add(global.shape_templates, attack_name, attack_template);
//
    //return attack_name;
//}


/// @description Generates attack shapes with more control and variety
/// @param {real} _attack - The attack power/complexity
/// @param {struct} game_control_object - The game control object
/// @param {string} [shape_type="random"] - Optional shape type to generate
function generate_attack_shape(_attack, game_control_object, shape_type = "random") {
    var max_width = obj_game_control.width;
    var max_height = 4; // Max row limit to prevent soft-locks
    var attack_template;
    var attack_name;
    
    // Get current game level for difficulty scaling
    var game_level = game_control_object.level;
    
    // Determine block type based on level
    var block_to_drop;
    
    if (game_level > 20) {
        // At high levels, chance of black blocks increases
        block_to_drop = (random(1) < 0.4) ? BLOCK.BLACK : BLOCK.RANDOM;
    } else if (game_level > 10) {
        // Mid levels - small chance of black blocks
        block_to_drop = (random(1) < 0.2) ? BLOCK.BLACK : BLOCK.RANDOM;
    } else {
        // Early levels - defined colors for better learning curve
        var color_blocks = [BLOCK.RED, BLOCK.GREEN, BLOCK.BLUE, BLOCK.YELLOW, BLOCK.PURPLE, BLOCK.PINK,  BLOCK.LIGHTBLUE, BLOCK.ORANGE, BLOCK.YELLOW];
        block_to_drop = color_blocks[irandom(array_length(color_blocks) - 1)];
    }
    
    // Generate different shapes based on shape_type
    if (shape_type == "random") {
        // Choose a random shape type with weighted probabilities
        var shape_types = ["rectangle", "L_shape", "Z_shape", "T_shape", "single_line"];
        var probabilities = [0.4, 0.2, 0.15, 0.15, 0.1]; // Weights for each shape
        
        var total_prob = 0;
        var chosen_prob = random(1);
        for (var i = 0; i < array_length(shape_types); i++) {
            total_prob += probabilities[i];
            if (chosen_prob < total_prob) {
                shape_type = shape_types[i];
                break;
            }
        }
    }
    
    // Create the appropriate shape template
    switch (shape_type) {
        case "rectangle":
            // Create a rectangular block pattern
            var width = irandom_range(1, min(3, max_width, _attack));
            var height = irandom_range(1, min(3, max_height, ceil(_attack / width)));
            
            attack_template = create_rectangle_pattern(width, height, block_to_drop);
            attack_name = "rect_" + string(width) + "x" + string(height) + "_" + string(irandom(9999));
            break;
            
        case "L_shape":
            // Create an L-shaped pattern
            var size = min(3, _attack);
            attack_template = create_L_pattern(size, block_to_drop);
            attack_name = "L_shape_" + string(size) + "_" + string(irandom(9999));
            break;
            
        case "Z_shape":
            // Create a Z-shaped pattern
            var size = min(3, _attack);
            attack_template = create_Z_pattern(size, block_to_drop);
            attack_name = "Z_shape_" + string(size) + "_" + string(irandom(9999));
            break;
            
        case "T_shape":
            // Create a T-shaped pattern
            var size = min(3, _attack);
            attack_template = create_T_pattern(size, block_to_drop);
            attack_name = "T_shape_" + string(size) + "_" + string(irandom(9999));
            break;
            
        case "single_line":
            // Create a single horizontal or vertical line
            var is_horizontal = irandom(1) == 0;
            var length = irandom_range(2, min(5, max_width, _attack));
            
            attack_template = create_line_pattern(length, is_horizontal, block_to_drop);
            attack_name = (is_horizontal ? "h_line_" : "v_line_") + string(length) + "_" + string(irandom(9999));
            break;
            
        default:
            // Fallback - original dynamic generation logic
            var shape_width = irandom_range(1, min(_attack, max_width));
            var shape_height = irandom_range(1, min(_attack div max_width + 1, max_height));
            
            // Prevent the 4th row from forming until previous rows are filled
            if (_attack >= (max_width * 3) && shape_height <= 4) {
                shape_height = 3;
            }
            
            attack_template = array_create(shape_height);
            var remaining_blocks = _attack;
            
            for (var _y = 0; _y < shape_height; _y++) {
                attack_template[_y] = array_create(shape_width, BLOCK.NONE);
                for (var _x = 0; _x < shape_width; _x++) {
                    if (remaining_blocks > 0) {
                        attack_template[_y][_x] = block_to_drop;
                        remaining_blocks--;
                    }
                }
                
                // Add L-Shape or gap randomness
                if (remaining_blocks > 0 && irandom(3) == 0) {
                    attack_template[_y][irandom(shape_width - 1)] = BLOCK.NONE;
                    remaining_blocks++;
                }
            }
            
            attack_name = "dynamic_" + string(_attack) + "_" + string(irandom(9999));
            break;
    }
    
    // Add the shape to the global templates
    
    ds_map_add(global.shape_templates, attack_name, attack_template);

    return attack_name;
}

/// @function create_rectangle_pattern
/// @description Creates a rectangular block pattern
function create_rectangle_pattern(width, height, block_type) {
    var pattern = array_create(height);
    
    for (var _y = 0; _y < height; _y++) {
        pattern[_y] = array_create(width, block_type);
    }
    
    return pattern;
}

/// @function create_L_pattern
/// @description Creates an L-shaped pattern
function create_L_pattern(size, block_type) {
    var pattern = array_create(size);
    
    // Initialize all positions to NONE
    for (var _y = 0; _y < size; _y++) {
        pattern[_y] = array_create(size, BLOCK.NONE);
    }
    
    // Fill in the L shape
    for (var _y = 0; _y < size; _y++) {
        pattern[_y][0] = block_type;  // Vertical part of L
    }
    
    for (var _x = 0; _x < size; _x++) {
        pattern[size-1][_x] = block_type;  // Horizontal part of L
    }
    
    return pattern;
}

/// @function create_Z_pattern
/// @description Creates a Z-shaped pattern
function create_Z_pattern(size, block_type) {
    var pattern = array_create(size);
    
    // Initialize all positions to NONE
    for (var _y = 0; _y < size; _y++) {
        pattern[_y] = array_create(size, BLOCK.NONE);
    }
    
    // Fill in the Z shape
    for (var _x = 0; _x < size-1; _x++) {
        pattern[0][_x] = block_type;  // Top horizontal line
    }
    
    // Middle diagonal
    for (var i = 0; i < size-1; i++) {
        pattern[i][size-i-1] = block_type;
    }
    
    for (var _x = 1; _x < size; _x++) {
        pattern[size-1][_x] = block_type;  // Bottom horizontal line
    }
    
    return pattern;
}

/// @function create_T_pattern
/// @description Creates a T-shaped pattern
function create_T_pattern(size, block_type) {
    var pattern = array_create(size);
    
    // Initialize all positions to NONE
    for (var _y = 0; _y < size; _y++) {
        pattern[_y] = array_create(size, BLOCK.NONE);
    }
    
    // Fill in the T shape
    for (var _x = 0; _x < size; _x++) {
        pattern[0][_x] = block_type;  // Top horizontal line of T
    }
    
    for (var _y = 1; _y < size; _y++) {
        pattern[_y][size/2] = block_type;  // Vertical line of T
    }
    
    return pattern;
}

/// @function create_line_pattern
/// @description Creates a line pattern (horizontal or vertical)
function create_line_pattern(length, is_horizontal, block_type) {
    if (is_horizontal) {
        // Horizontal line
        var pattern = array_create(1);
        pattern[0] = array_create(length, block_type);
        return pattern;
    } else {
        // Vertical line
        var pattern = array_create(length);
        for (var _y = 0; _y < length; _y++) {
            pattern[_y] = array_create(1, block_type);
        }
        return pattern;
    }
}
