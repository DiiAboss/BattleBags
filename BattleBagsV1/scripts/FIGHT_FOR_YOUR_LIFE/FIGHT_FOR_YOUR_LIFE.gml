function process_fight_for_your_life(_self, danger_row)
{
    var in_danger = false;
    var width     = _self.board_width;
    var grid      = _self.grid;
    var gem_size  = _self.gem_size;
    var global_y_offset = _self.global_y_offset;
    var combo     = self.combo;
    
    for (var i = 0; i < width; i++) {
        for (var _y = 0; _y < danger_row; _y++)
        {
            if (grid[i, _y].type != BLOCK.NONE && !grid[i, _y].falling && grid[i, _y].fall_delay < grid[i, _y].max_fall_delay && !grid[i, _y].is_enemy_block) { 
            
                if (combo >= 0)
                {
                    in_danger = true;
                }
            }
        }
    }
    
    return (in_danger);
}
