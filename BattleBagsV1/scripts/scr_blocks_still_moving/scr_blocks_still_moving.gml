function blocks_still_moving(_self) {
	var width = _self.width;
	var height = _self.height;
	
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            var gem = _self.grid[i, j];

            if (gem.type != -1) { // Only check valid gems
                if (gem.falling) {
                    return true; // 🚨 A block is still moving, so do not reset combo!
                }
            }
        }
    }
    return false; // ✅ All blocks are settled
}