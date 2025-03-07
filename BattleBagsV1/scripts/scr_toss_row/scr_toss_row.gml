function toss_down_row(_self, black_block = false, start_x = -1) {
    var width = _self.width;
    var height = _self.height;
    var gem_size = _self.gem_size;
    
    for (var i = 0; i < width; i++) 
	{
		var new_gem = create_block(black_block ? BLOCK.BLACK : BLOCK.RANDOM);
		
        _self.grid[i, 0] = new_gem; // ✅ Place it in the grid at row 0
        new_gem.falling = true; // ✅ Mark as falling
        new_gem.fall_delay = 0; // **Delay before falling**
    }
    drop_blocks(_self); // ✅ Ensure drop_blocks() will handle them
}