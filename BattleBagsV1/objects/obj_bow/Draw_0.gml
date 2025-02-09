/// @description
if (can_draw)
{
	draw_sprite_ext(sprite_index, 0, x, y, 1.2, 1.2, image_angle, c_white, 1);

	draw_text(x, y-10, direction);
	draw_circle(final_pos[0], final_pos[1], 32, true);
}