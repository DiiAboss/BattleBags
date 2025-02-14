/// @description
/// 



var game_control = obj_game_control;
var board_x_offset = game_control.board_x_offset;
var width = game_control.width;
var gem_size = game_control.gem_size;
var draw_y_start = gem_size * 5;


draw_attack_preview(
    board_x_offset + (width * gem_size) + 16, // X position
    draw_y_start + 64,                        // Y position
    256,                                      // Preview size
    32,                                       // Grid size
    4                                         // Grid spacing
);