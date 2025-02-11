/// @description Draws the preview box for upcoming enemy attacks.
/// @param {real} _x - X position of the preview.
/// @param {real} _y - Y position of the preview.
/// @param {real} _preview_size - Size of the preview box.
/// @param {real} _grid_size - Size of individual grid cells.
/// @param {real} _grid_spacing - Spacing between grid blocks.

function draw_attack_preview(_x, _y, _preview_size, _grid_size, _grid_spacing) {
    var max_attacks_shown = 5;
    var queue_size = min(ds_list_size(global.enemy_attack_queue), max_attacks_shown);

    for (var i = 0; i < queue_size; i++) {
        var attack_offset_y = _y + (i * (_preview_size + 8));
        draw_rectangle(_x, attack_offset_y, _x + _preview_size, attack_offset_y + _preview_size, true);
    }

    if (queue_size > 0) {
        for (var attack_index = 0; attack_index < queue_size; attack_index++) {
            var next_attack = ds_list_find_value(global.enemy_attack_queue, attack_index);
            var attack_offset_y = _y + (attack_index * (_preview_size + 8));

            if (attack_index == 0 && instance_exists(obj_enemy_basic_parent)) {
                var enemy = instance_find(obj_enemy_basic_parent, 0);
                var attack_progress = enemy.attack_timer / enemy.max_attack_timer;
                var bar_height = _preview_size * attack_progress;
                draw_set_alpha(0.5);
                draw_rectangle(_x, attack_offset_y, _x + _preview_size, attack_offset_y + bar_height, false);
                draw_set_alpha(1);
            }

            // ✅ If the attack is not a basic or special attack, display text
            if (attack_index > 0 || next_attack == "FREEZE") {
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_text(_x + _preview_size / 2, attack_offset_y + _preview_size / 2, next_attack);
            } else if (ds_map_exists(global.shape_templates, next_attack)) {
                // ✅ Draw normal attack previews
                    var attack_shape = ds_map_find_value(global.shape_templates, next_attack);
                    var shape_width = array_length(attack_shape[0]);
                    var shape_height = array_length(attack_shape);

                    var total_width = (shape_width * _grid_size) + ((shape_width - 1) * _grid_spacing);
                    var total_height = (shape_height * _grid_size) + ((shape_height - 1) * _grid_spacing);
                    var offset_x = _x + (_preview_size - total_width) / 2;
                    var offset_y = attack_offset_y + (_preview_size - total_height) / 2;

                    for (var j = 0; j < shape_height; j++) {
                        for (var i = 0; i < shape_width; i++) {
                            var grid_x = offset_x + (i * (_grid_size + _grid_spacing));
                            var grid_y = offset_y + (j * (_grid_size + _grid_spacing));

                            if (attack_shape[j][i] != BLOCK.NONE) {
                                draw_rectangle(grid_x + 2, grid_y + 2, grid_x + _grid_size - 2, grid_y + _grid_size - 2, false);
                        }
                    }
                }
            }
        }
    }
}

