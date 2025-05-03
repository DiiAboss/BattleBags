

draw_console(self, console_active);


if (room == rm_map_room_test)
{
    draw_sprite(spr_player_arrow, 0, current_run.overworld_x, current_run.overworld_y);
    
    draw_sprite(spr_enemy_attack_preview, 0, current_run.target_x, current_run.target_y);
    
    draw_line(current_run.start_x, current_run.start_y, current_run.target_x, current_run.target_y);
    
    draw_set_color(c_white);
}