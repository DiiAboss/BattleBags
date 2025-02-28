/// @description Draw Enemy - Displays health, attack timer, and preview.

if !(obj_game_control.game_over_state)
{
	draw_sprite(my_sprite, 0, x, y);
}


var hp_bar_width     = 256;
var hp_bar_height    = 16;
var draw_hp_x        = x - (hp_bar_width * 0.5);
var draw_hp_y        = y + 96;
var hp_percent       = (hp / max_hp);

draw_rectangle_color(draw_hp_x, 
                     draw_hp_y, 
                     draw_hp_x + hp_bar_width, 
                     draw_hp_y + hp_bar_height, 
                     c_red, c_red, c_red, c_red, false);

draw_rectangle_color(draw_hp_x, 
                     draw_hp_y, 
                     draw_hp_x + (hp_bar_width * hp_percent), 
                     draw_hp_y + hp_bar_height, 
                     c_green, c_green, c_green, c_green, false);


for (var _shield = 0; _shield < shield_amount; _shield++)
{
    var shield_size      = hp_bar_width / max_shield_amount;
    var draw_shield_x    = draw_hp_x + (shield_size * _shield)
    var draw_shield_x2   = draw_shield_x + shield_size; 
    
    draw_rectangle_color(draw_shield_x, 
                         draw_hp_y, 
                         draw_shield_x2, 
                         draw_hp_y + hp_bar_height, 
                         c_white, c_blue, c_blue, c_white, false);
    
    draw_rectangle_color(draw_shield_x, 
                         draw_hp_y, 
                         draw_shield_x2, 
                         draw_hp_y + hp_bar_height, 
                         c_blue, c_blue, c_blue, c_blue, true);
}


draw_text(x, y - 100, "ATTACK_QUEUE" + string(attack_timer));
draw_text(x, y - 140, "QUEUED_ATTACK_QUEUE" + string(queued_attack_timer));

/// ✅ Draw Attack Preview Above Enemy
var preview_block_size = 8;
var preview_x = x - (preview_block_size * 4); // Center preview above enemy
var preview_y = y - (32 * 4);                 // Space above enemy

if (is_array(enemy_attack_preview)) {
    var rows = array_length(enemy_attack_preview);

    for (var row = 0; row < rows; row++) {
        if (is_array(enemy_attack_preview[row])) {
            var cols = array_length(enemy_attack_preview[row]);

            for (var col = 0; col < cols; col++) {
                var block_type = enemy_attack_preview[row][col];

                if (block_type != BLOCK.NONE) {
                    var spr_x = preview_x + (col * preview_block_size);
                    var spr_y = preview_y + (row * preview_block_size);
                    
                    draw_sprite(spr_enemy_attack_preview, block_type, spr_x, spr_y);
                }
            }
        }
    }
}

 animate_attack_targets(self, "FREEZE"); // ✅ Show animation first
 animate_attack_targets(self, "SLIME"); // ✅ Show animation first


instance_create_depth(x, y, depth - 1, obj_conveyor_belt);

animate_attack_targets(self, "FREEZE"); // ✅ Show animation first
animate_attack_targets(self,  "SLIME"); // ✅ Show animation first