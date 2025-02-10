function destroy_block(_self, _x, _y) {
    var block = _self.grid[_x, _y];

    if (block == BLOCK.NONE) return; // Prevent null errors
	
	if (_y > _self.bottom_playable_row) return;
	
    // ✅ If BLACK, store it for transformation (don't destroy immediately)
    if (block.type == BLOCK.BLACK) {
        ds_list_add(global.black_blocks_to_transform, [_x, _y]);
        return;
    }
	
    // ✅ Otherwise, process the destruction normally
    _self.grid[_x, _y] = create_block(BLOCK.NONE); // Remove block from grid
}

