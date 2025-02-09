/// @description Insert description here
// You can write your code in this editor
draw_self();

if (damage_timer > 0)
{
	draw_text(x-64, y-244, string(total_damage));
}

draw_text(x-64, y-228, string(hp) + " / " + string(max_hp));
draw_text(x-64, y-196, string(attack_timer) + " / " + string(max_attack_timer));
draw_text(x-64, y-260, "Total_Attacks: " + string(total_attacks));
draw_text(x-64, y-280, "Attacks_Until_Special: " + string(total_attacks % attacks_until_special_attack));
draw_text(x-64, y-300, "Attacks_TIMER_INC: " + string(global.enemy_timer_game_speed * (global.gameSpeed / obj_game_control.game_speed_default)));


/// @description Draw Enemy Attack Preview Above Head


// ✅ Draw Attack Preview Above Enemy
var preview_x = x - (8 * 4); // Center preview above enemy
var preview_y = y - (32 * 4); // Space above enemy

if (is_array(self.enemy_attack_preview)) {
    var rows = array_length(self.enemy_attack_preview);

    for (var row = 0; row < rows; row++) {
        if (is_array(self.enemy_attack_preview[row])) {
            var cols = array_length(self.enemy_attack_preview[row]);

            for (var col = 0; col < cols; col++) {
                var block_type = self.enemy_attack_preview[row][col];

                if (block_type != BLOCK.NONE) {
                    draw_sprite(spr_enemy_attack_preview, block_type, preview_x + (col * 8), preview_y + (row * 8));
                }
            }
        }
    }
}


