// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function all_blocks_landed(_self) {
	width = _self.width;
	height = _self.height;
	
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            if (_self.gem_y_offsets[i, j] < 0) 
			{
                return false; // There's at least one still falling
            }
        }
    }
    return true; // Everything is settled
}