/// @description
/// 

var hover_amount = 8;
var hover = hover_draw(hover_amount);

draw_sprite(sprite, 0, x, y + hover);
draw_sprite(hand_sprite, 0, hand_x, hand_y + hover);

draw_rectangle_color(conveyor.conveyor_x_start - 64, range_min, conveyor.conveyor_x_start + conveyor.conveyor_width, range_max, c_red, c_red, c_red, c_red, true)