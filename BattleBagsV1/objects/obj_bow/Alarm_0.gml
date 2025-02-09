/// @description
speed = 8;
final_pos[0] = board_x_offset + (final_pos[0] * gem_size) + 32;
final_pos[1] = (final_pos[1] * gem_size) + 32 + obj_game_control.global_y_offset;
direction = point_direction(x, y, final_pos[0], final_pos[1]);

image_angle = direction;

can_draw = true;