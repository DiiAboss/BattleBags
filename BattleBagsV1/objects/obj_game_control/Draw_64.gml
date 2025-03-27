/// @description

if !global.paused
{
    for (var _b = 0; _b < array_length(big_block_types_on_grid) - 1; _b ++)
    {
        draw_text(128, 256 + (32 * _b), string(big_block_types_on_grid[_b]));
    } 
}
