/// @description

//draw_gui_neon_shader_stats(self)
var arr = array_length(global.color_spawn_weight);
for (var _i = 0; _i < arr; _i++)
{
    draw_text(64, 256 + (32 * _i), string(_i) + ": " + string(global.color_spawn_weight[_i]));
    
}


for (var _b = 0; _b < array_length(big_block_types_on_grid) - 1; _b ++)
{
    draw_text(128, 256 + (32 * _b), string(big_block_types_on_grid[_b]));
}