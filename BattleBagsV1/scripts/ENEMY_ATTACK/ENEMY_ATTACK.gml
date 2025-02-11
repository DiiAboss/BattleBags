

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

/// @description Generates a random attack shape dynamically.
function generate_attack_shape(_attack, game_control_object) {
    var max_width = obj_game_control.width;
    var max_height = 4; // Max row limit to prevent soft-locks

    var shape_width = irandom_range(1, min(_attack, max_width));
    var shape_height = irandom_range(1, min(_attack div max_width + 1, max_height));

    var game_level = game_control_object.level;
    var block_to_drop = (game_level > 10) ? BLOCK.BLACK : BLOCK.RANDOM;

    // ✅ Prevent the 4th row from forming until previous rows are filled
    if (_attack >= (max_width * 3) && shape_height <= 4) {
        shape_height = 3;
    }

    var attack_template = array_create(shape_height);
    var remaining_blocks = _attack;

    for (var _y = 0; _y < shape_height; _y++) {
        attack_template[_y] = array_create(shape_width, BLOCK.NONE);

        for (var _x = 0; _x < shape_width; _x++) {
            if (remaining_blocks > 0) {
                attack_template[_y][_x] = block_to_drop;
                remaining_blocks--;
            }
        }

        // ✅ Add L-Shape or gap randomness
        if (remaining_blocks > 0 && irandom(3) == 0) {
            attack_template[_y][irandom(shape_width - 1)] = BLOCK.NONE;
            remaining_blocks++;
        }
    }

    var attack_name = "dynamic_" + string(_attack) + "_" + string(irandom(9999));
    ds_map_add(global.shape_templates, attack_name, attack_template);

    return attack_name;
}



