/// @description Draw Enemy - Displays health, attack timer, and preview.

if !(obj_game_control.game_over_state)
{

	draw_sprite(my_sprite, 0, x, y);
    
    
    
}
///// ✅ Draw Damage Indicator
//if (damage_timer > 0) {
    //draw_text(x - 64, y - 244, string(total_damage));
//}
//
///// ✅ Draw Enemy Stats
//draw_text(x - 64, y - 228, string(hp) + " / " + string(max_hp));
//draw_text(x - 64, y - 196, string(attack_timer) + " / " + string(max_attack_timer));
//draw_text(x - 64, y - 260, "Total Attacks: " + string(total_attacks));
//draw_text(x - 64, y - 280, "Attacks Until Special: " + string(total_attacks % attacks_until_special_attack));
//draw_text(x - 64, y - 300, "Attack Timer Increase: " + string(global.enemy_timer_game_speed * (global.gameSpeed / obj_game_control.game_speed_default)));
//
    //var health_percentage = (hp / max_hp);
    //draw_rectangle(x - 196, y - 196, x - 196 + (392 * health_percentage), y - 164, false);
//
///// ✅ Draw Attack Preview Above Enemy
//var preview_x = x - (8 * 4); // Center preview above enemy
//var preview_y = y - (32 * 4); // Space above enemy
//
//if (is_array(enemy_attack_preview)) {
    //var rows = array_length(enemy_attack_preview);
//
    //for (var row = 0; row < rows; row++) {
        //if (is_array(enemy_attack_preview[row])) {
            //var cols = array_length(enemy_attack_preview[row]);
//
            //for (var col = 0; col < cols; col++) {
                //var block_type = enemy_attack_preview[row][col];
//
                //if (block_type != BLOCK.NONE) {
                    //draw_sprite(spr_enemy_attack_preview, block_type, preview_x + (col * 8), preview_y + (row * 8));
                //}
            //}
        //}
    //}
//}
//
 //animate_attack_targets(self, "FREEZE"); // ✅ Show animation first
 //animate_attack_targets(self, "SLIME"); // ✅ Show animation first
//}



