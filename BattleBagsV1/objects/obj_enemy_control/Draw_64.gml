/// @description
if (attack_preview_active || attack_preview_alpha > 0) {
    draw_set_alpha(attack_preview_alpha);
    draw_set_color(c_black);
    
    // Draw the Background of the Preview Box
    draw_rectangle(attack_preview_box_x, attack_preview_box_y, 
                attack_preview_box_x + attack_preview_box_width, 
                attack_preview_box_y + attack_preview_box_height, 
                true);
    
    // Draw the Border
    draw_set_color(c_white);
    draw_rectangle(attack_preview_box_x, attack_preview_box_y, 
                attack_preview_box_x + attack_preview_box_width, 
                attack_preview_box_y + attack_preview_box_height, 
                false);
    
    // Draw Enemy Attack (Modify to match your enemy's attack visuals)
    var enemy_attack_x = attack_preview_box_x + (attack_preview_box_width / 2);
    var enemy_attack_y = attack_preview_box_y + (attack_preview_box_height / 2);
    
    //draw_sprite(spr_enemy_attack, 0, enemy_attack_x, enemy_attack_y);

    draw_set_alpha(1); // Reset alpha
}
