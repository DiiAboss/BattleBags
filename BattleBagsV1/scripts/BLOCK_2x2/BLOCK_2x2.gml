function spawn_2x2_block(_self, _x, _y, _type) {
    if (_x < 0 || _x >= _self.width - 1 || _y < 0 || _y >= _self.height - 1) return;

    // ✅ Check if space is available (NO big blocks already there)
    if (_self.grid[_x, _y].is_big || _self.grid[_x + 1, _y].is_big ||
        _self.grid[_x, _y + 1].is_big || _self.grid[_x + 1, _y + 1].is_big) {
        return; // ❌ Space is occupied, do NOT spawn
    }
	
	// ✅ Check if space is available (NO big blocks already there)
    if (_self.grid[_x, _y].popping || _self.grid[_x + 1, _y].popping ||
        _self.grid[_x, _y + 1].popping || _self.grid[_x + 1, _y + 1].popping) {
        return; // ❌ Space is occupied, do NOT spawn
    }
	


    // ✅ Clear the 2x2 space **before** placing the big block
	destroy_block(self, _x, _y);
	destroy_block(self, _x +1, _y);
	destroy_block(self, _x, _y + 1);
	destroy_block(self, _x + 1, _y + 1);
    //_self.grid[_x, _y]         = create_block(BLOCK.NONE);
    //_self.grid[_x + 1, _y]     = create_block(BLOCK.NONE);
    //_self.grid[_x, _y + 1]     = create_block(BLOCK.NONE);
    //_self.grid[_x + 1, _y + 1] = create_block(BLOCK.NONE);

    // ✅ Generate unique, non-zero group_id
    var group_id = irandom_range(1, 999999); // ✅ No -1 or 0

    // ✅ Create and assign the **big parent block**
    var big_gem = create_block(_type);
    big_gem.is_big     = true;
    big_gem.group_id   = group_id;
    big_gem.big_parent = [_x, _y];

    _self.grid[_x, _y] = big_gem; // Place **actual big block**

    // ✅ Create & assign **child parts**
    for (var _dx = 0; _dx < 2; _dx++) {
        for (var _dy = 0; _dy < 2; _dy++) {
            if (_dx == 0 && _dy == 0) continue; // **Skip parent block**

            var child_gem = create_block(_type);
            child_gem.is_big     = true;
            child_gem.group_id   = group_id;
            child_gem.big_parent = [_x, _y];

            _self.grid[_x + _dx, _y + _dy] = child_gem; // Assign child parts
        }
    }
}
