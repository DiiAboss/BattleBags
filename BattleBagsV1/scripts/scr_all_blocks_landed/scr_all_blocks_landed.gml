// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function all_blocks_landed(_self) {
	var width = _self.width;
	var height = _self.height;
	var bottom_row = _self.bottom_playable_row;
	
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < bottom_row; j++) {
			//if (is_block_falling(block))
			//if (_self.gem_y_offsets[i, j] < 0) 
            var block = grid[i, j];
			if (_self.gem_y_offsets[i, j] < 0) 
			{
                return false; // There's at least one still falling
            }
        }
    }
    return true; // Everything is settled
}