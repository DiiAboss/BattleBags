function destroy_rows_from_bottom(_self, amount_of_rows)
{
    var width = _self.width;
    var height = _self.height;
    var rows_to_destroy = height - amount_of_rows;
    
    for (var _x = 0; _x < width; _x++)
        {
            for (var _y = height; _y >= rows_to_destroy; _y--)
            {
                _self.grid[_x, _y] = create_block(BLOCK.NONE, POWERUP.NONE);
            }
        }
}