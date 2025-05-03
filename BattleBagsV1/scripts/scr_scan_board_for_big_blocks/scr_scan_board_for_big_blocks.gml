// Script Created By DiiAboss AKA Dillon Abotossaway
// Scan the board for big blocks
function scan_board_for_big_blocks(_self)
{
    var big_block_types_on_grid = [];
    
    var big_blocks = [];
    var bottom_row = _self.bottom_playable_row;
    var top_row    = _self.topmost_row;
    var width      = _self.board_width;
    
    
    show_debug_message("Scanning for big blocks");
    for (var _x = 0; _x < width - 1; _x++)
    {
        for (var _y = top_row; _y < bottom_row; _y++)
        {
            var block      = _self.grid[_x, _y];
            var is_parent  = (block.big_parent[0] == _x) && (block.big_parent[1] == _y);
            //if !(is_parent) continue;
            
            if (block.type != BLOCK.NONE) && block.is_big && block.type != BLOCK.MEGA
            {
                show_debug_message("Found big block at [" + string(_x) + "," + string(_y) + "]");
                {
                    if (!array_contains(big_blocks, block.group_id)) {
                        show_debug_message("Added Group ID [" + string(block.group_id) + "] with type: " + string(block.type));
                        array_push(big_blocks, block.group_id);
                        array_push(_self.big_block_types_on_grid , block.type);
                    }
                }
            } 
        }
    }
    
   
    
}




function return_bottom_row_positions_of_types_excluding(_self, exclude_type)
{
    var temp_array = [];
    var width = _self.board_width;
    var bottom_row = _self.bottom_playable_row;
    
    for (var _block = 0; _block < width - 1; _block++)
    {
        var _block_type = _self.grid[_block, bottom_row].type;
        
        if (_block_type != exclude_type)
        {
            array_push(temp_array, _block); // Push Position into temp array
        }
    }
    
    return temp_array;
}
