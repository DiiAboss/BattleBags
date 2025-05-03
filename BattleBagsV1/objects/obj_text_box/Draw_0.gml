/// @description

var hover = 4;
var hplus = hover_draw(hover)

draw_sprite_ext(spr_textbox, -1, x, y, xscale, yscale, 0, c_black, 0.5);
draw_clay_text_wave(my_text, x + 32, y + 32, 6, 0.25, 1, 0.5);
//draw_clay_text(my_text, x + 32, y + 32 - (hplus * 0.5));