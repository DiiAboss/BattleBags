function destroy_block(player, _x, _y) {
    var block = player.grid[_x, _y];

    if (block == BLOCK.NONE) return noone; // Prevent null errors
	
	if (_y > player.bottom_playable_row) return noone;
	
    // ✅ If BLACK, store it for transformation (don't destroy immediately)
    if (block.type == BLOCK.BLACK) {
        ds_list_add(global.black_blocks_to_transform, [_x, _y]);
        return;
    }
	
    // ✅ Otherwise, process the destruction normally
    player.grid[_x, _y] = create_block(player, BLOCK.NONE); // Remove block from grid"
    
    return player.grid[_x, _y];
}

