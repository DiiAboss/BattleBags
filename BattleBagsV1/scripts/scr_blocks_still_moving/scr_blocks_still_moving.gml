function blocks_still_moving(_self) {
    var width = _self.width;
    var height = _self.height;

    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            var gem = _self.grid[i, j];

            if (gem.type != -1 && !gem.is_enemy_block) { // ✅ Ignore enemy blocks
                if (gem.falling || gem.fall_delay > 0) {
                    return true; 
                }
            }
        }
    }
    return false; 
}
