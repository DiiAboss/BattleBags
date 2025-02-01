//function blocks_still_moving(_self) {
//    var width = _self.width;
//    var height = _self.height;

//    for (var i = 0; i < width; i++) {
//        for (var j = 0; j < height; j++) {
//            var gem = _self.grid[i, j];

//            if (gem.type != -1 && !gem.is_enemy_block) { // ✅ Ignore enemy blocks
//                if (gem.falling || gem.fall_delay > 0 || gem.popping) {
//                    return true; 
//                }
//            }
//        }
//    }
//    return false; 
//}


function blocks_still_moving(_self) {
    var width = _self.width;
    var height = _self.height;
    var still_moving = false;

    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            var gem = _self.grid[i, j];

            // 🟥 **Ignore enemy blocks (optional)**
            if (!gem.is_enemy_block) && (gem.type != -1) {
                // 🔥 Ensure falling, popping, OR movement offsets are considered
                if (gem.falling || gem.fall_delay > 0 || gem.pop_timer > 0 || gem.shake_timer > 0 || gem.popping) {
                    still_moving = true;
                }
            }
        }
    }

    return still_moving;
}