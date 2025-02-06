//function start_swap(_self, ax, ay, bx, by) {
//    if (_self.swap_in_progress) return; // Prevent stacking swaps
	 
//	  // If either block is part of a 2x2 block, ensure all pieces move together
//    var gemA = _self.grid[ax, ay];
//    var gemB = _self.grid[bx, by];

//    if (gemA.is_big || gemB.is_big) {
//        // Prevent swaps that would break the block apart
//        if (gemA.group_id != gemB.group_id) return;
//		var parentA = gemA.big_parent;
//        var parentB = gemB.big_parent;

//        if (parentA[0] != parentB[0] || parentA[1] != parentB[1]) return; // Ensure swapping whole block
//    }
	
//    // If the row is currently shifting, store swap **before the transition completes**
//    //if (_self.global_y_offset == 0) {
//        global.swap_queue.active = true;
//        global.swap_queue.ax = ax;
//        global.swap_queue.ay = ay;
//        global.swap_queue.bx = bx;
//        global.swap_queue.by = by;
//        //return; // Don't execute yet
//    //}
	
//	var _pitch = clamp(1 + (0.05 * _self.combo), 0.5, 5);
//	audio_play_sound(snd_swap_test_1, 10, false, 0.1, 0, _pitch);
	

	
//    execute_swap(_self, ax, ay, bx, by); // ✅ Otherwise, execute immediately
//}

function start_swap(_self, ax, ay, bx, by) {
    if (_self.swap_in_progress) return; // Prevent stacking swaps

    var gemA = _self.grid[ax, ay];
    var gemB = _self.grid[bx, by];

    if (gemA.is_big || gemB.is_big) {
        if (gemA.group_id != gemB.group_id) return;
        var parentA = gemA.big_parent;
        var parentB = gemB.big_parent;

        if (parentA[0] != parentB[0] || parentA[1] != parentB[1]) return; // Ensure swapping whole block
    }


    // ✅ Execute the swap normally if no shifting is happening
    execute_swap(_self, ax, ay, bx, by);
}





function execute_swap(_self, ax, ay, bx, by) {
    var width = _self.width;
    var height = _self.height;

    if (
        ax >= 0 && ax < width && ay >= 0 && ay < height &&
        bx >= 0 && bx < width && by >= 0 && by < height
    ) {
        if (is_being_destroyed(ax, ay) || is_being_destroyed(bx, by)) return;
        if (_self.grid[ax, ay].frozen || _self.grid[bx, by].frozen) return;
        if (_self.grid[ax, ay].type == BLOCK.MEGA || _self.grid[bx, by].type == BLOCK.MEGA) return;

        // 🔹 If the row just finished shifting, update positions ONLY IF IT WASN’T ALREADY SHIFTED
        if (_self.global_y_offset == 0) {
            _self.swap_info.from_x = ax;
            _self.swap_info.from_y = ay + 1;
            _self.swap_info.to_x   = bx;
            _self.swap_info.to_y   = by + 1;
            _self.swap_info.progress = 0;
        }
        else
        {
            _self.swap_in_progress = true;
            _self.swap_info.from_x = ax;
            _self.swap_info.from_y = ay;
            _self.swap_info.to_x   = bx;
            _self.swap_info.to_y   = by;
            _self.swap_info.progress = 0;
            _self.swap_info.speed = 0.15;
        }

        //global.swap_queue.active = false; // Clear queue after execution
    }
}




//function execute_swap(_self,  ax, ay, bx, by) {
//    var width =_self.width;
//	var height = _self.height;
	
//	if (
//        ax >= 0 && ax < width && ay >= 0 && ay < height &&
//        bx >= 0 && bx < width && by >= 0 && by < height
//    ) {
//        if (is_being_destroyed(ax, ay) || is_being_destroyed(bx, by)) return;
//        if (_self.grid[ax, ay].frozen || _self.grid[bx, by].frozen) return;
//        if (_self.grid[ax, ay].type == BLOCK.MEGA || _self.grid[bx, by].type == BLOCK.MEGA) return;
		
//        _self.swap_in_progress = true;
//        _self.swap_info.from_x = ax;
//        _self.swap_info.from_y = ay;
//        _self.swap_info.to_x   = bx;
//        _self.swap_info.to_y   = by;
//        _self.swap_info.progress = 0;
//        _self.swap_info.speed = 0.05;
//    }
//}