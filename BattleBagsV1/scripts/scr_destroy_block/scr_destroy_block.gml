function destroy_block(_self, _x, _y) {
    var gem = _self.grid[_x, _y];

    if (gem == -1) return; // Prevent null errors
	
	if (_y > _self.bottom_playable_row) return;
	
    // ✅ If BLACK, store it for transformation (don't destroy immediately)
    if (gem.type == BLOCK.BLACK) {
        ds_list_add(global.black_blocks_to_transform, [_x, _y]);
        return;
    }
	
    // ✅ Otherwise, process the destruction normally
    _self.grid[_x, _y] = create_gem(BLOCK.NONE); // Remove block from grid
}

