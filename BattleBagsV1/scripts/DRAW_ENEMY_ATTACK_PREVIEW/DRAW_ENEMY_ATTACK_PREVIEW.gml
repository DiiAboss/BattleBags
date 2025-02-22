/// @description Draws the preview box for upcoming enemy attacks.
/// @param {real} _x - X position of the preview.
/// @param {real} _y - Y position of the preview.
/// @param {real} _preview_size - Size of the preview box.
/// @param {real} _grid_size - Size of individual grid cells.
/// @param {real} _grid_spacing - Spacing between grid blocks.

function draw_attack_preview(_x, _y, _preview_size, _grid_size, _grid_spacing) {

    var queue_size = ds_list_size(global.enemy_attack_queue);


    var attack_offset_y = _y + (_preview_size + 8);
    draw_rectangle(_x, attack_offset_y, _x + _preview_size, attack_offset_y + _preview_size, true);

    
    if (queue_size > 0) {
        var next_attack = ds_list_find_value(global.enemy_attack_queue, 0);
        var enemy = instance_find(obj_enemy_basic_parent, 0);
        if (enemy == noone) return;
        
        var attack_progress = enemy.queued_attack_timer / enemy.max_queued_attack_timer;
        var bar_height = _preview_size * attack_progress;
        draw_set_alpha(0.5);
        draw_rectangle(_x, attack_offset_y, _x + _preview_size, attack_offset_y + bar_height, false);
        draw_set_alpha(1);
        
        


            
        
        

            switch(next_attack)
            {
                case "FREEZE":
                    draw_sprite(spr_ice_cover, 0, _x + (_preview_size * 0.5), attack_offset_y +  + (_preview_size * 0.5));
                
                
                   for (var i = 0; i < ds_list_size(enemy.target_blocks); i++) {
                    var target = ds_list_find_value(enemy.target_blocks, i);
                    var target_x = target[0];
                    var target_y = target[1];

                        var px = (target_x * obj_game_control.gem_size) + obj_game_control.board_x_offset + 32;
                        var py = (target_y * obj_game_control.gem_size) + obj_game_control.global_y_offset + 32;
                        draw_sprite(spr_enemy_gem_overlay, 0, px, py);
                           
                       }
                    break;
                case "SLIME":
                    draw_sprite(spr_goo_cover, 0, _x + (_preview_size * 0.5), attack_offset_y +  + (_preview_size * 0.5));
                                
                    for (var i = 0; i < ds_list_size(enemy.target_blocks); i++) {
                        var target = ds_list_find_value(enemy.target_blocks, i);
                        var target_x = target[0];
                        var target_y = target[1];
    
                            var px = (target_x * obj_game_control.gem_size) + obj_game_control.board_x_offset + 32;
                            var py = (target_y * obj_game_control.gem_size) + obj_game_control.global_y_offset + 32;
                            draw_sprite(spr_enemy_gem_overlay, 0, px, py);
                            
                        }
                    break;
                case "BLOCK":
                    draw_sprite(spr_gameOver, 0, _x + (_preview_size * 0.5), attack_offset_y +  + (_preview_size * 0.5));
                    break;
                default:
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
                    break;
            
            
            
        }
        
    }
}

