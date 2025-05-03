function destroy_rows_from_bottom(player, amount_of_rows)
{
    var width = player.board_width;
    var height = player.board_height;
    var rows_to_destroy = height - amount_of_rows;
    
    for (var _x = 0; _x < width; _x++)
        {
            for (var _y = height; _y >= rows_to_destroy; _y--)
            {
                player.grid[_x, _y] = create_block(player, BLOCK.NONE, POWERUP.NONE);
            }
        }
}