/// @description Insert description here
// You can write your code in this editor
if (global.paused) {
    draw_set_alpha(0.6);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(room_width / 2, room_height / 2, "PAUSED\nPress P to Resume");
	draw_set_halign(fa_left);
}