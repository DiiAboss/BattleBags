/// @description
// Draw event for the push effect:
/// @description Draw push effect
draw_set_alpha(effect_alpha);
draw_set_color(c_white);
draw_circle(x, y, radius * (effect_scale/max_scale), false);
draw_set_alpha(1);