
// Script Created By DiiAboss AKA Dillon Abotossaway
///@function start_swap
///
///@description Initiates a swap between two gems while ensuring valid swap conditions.
///
///@param {id} _self - The game object managing the board.
///@param {real} ax - The x-coordinate of the first gem.
///@param {real} ay - The y-coordinate of the first gem.
///@param {real} bx - The x-coordinate of the second gem.
///@param {real} by - The y-coordinate of the second gem.
///
function start_swap(_self, ax, ay, bx, by) {
    if (_self.swap_in_progress) return; // Prevent stacking swaps

    // ✅ Ensure swap is within playable area
    if (ay < top_playable_row || ay > bottom_playable_row ||
        by < top_playable_row || by > bottom_playable_row) return;

    var gemA = _self.grid[ax, ay];
    var gemB = _self.grid[bx, by];

    // ✅ Prevent swapping `big` blocks if they belong to different groups
    if (gemA.is_big || gemB.is_big) {
        if (gemA.group_id != gemB.group_id) return;
        var parentA = gemA.big_parent;
        var parentB = gemB.big_parent;

        if (parentA[0] != parentB[0] || parentA[1] != parentB[1]) return; // Ensure swapping whole block
    }

    // ✅ Execute the swap normally if no shifting is happening
    execute_swap(_self, ax, ay, bx, by);
}


function process_swap(_self, swap_info)
{
    if (global.swap_queue.active) {
        // ✅ Make sure we only shift the row if a swap was NOT already shifted
        if (_self.global_y_offset == 0) {
            global.swap_queue.ay -= 1;
            global.swap_queue.by -= 1;
        }
    
        // ✅ Execute the swap AFTER adjusting its position
        execute_swap(self, global.swap_queue.ax, global.swap_queue.ay, global.swap_queue.bx, global.swap_queue.by);
        
        global.swap_queue.active = false; // Clear the swap queue
    }
    
    
	if (_self.swap_in_progress) {
	    swap_info.progress += swap_info.speed;

	    // 🛑 Check if the swap is happening **mid-shift** (before progress reaches 1)
	    if (swap_info.progress < 1 && _self.global_y_offset == 0) {
	        // 🔹 Move swap targets UP by one row since the board just shifted
	        swap_info.from_y -= 1;
	        swap_info.to_y -= 1;
	    }

	    if (swap_info.progress >= 1) {
	        swap_info.progress = 1;

	        // ✅ Ensure the swap happens at the correct row based on whether we just shifted
	        if (_self.global_y_offset != 0) {
	            var temp = grid[swap_info.from_x, swap_info.from_y];
	            _self.grid[swap_info.from_x, swap_info.from_y] = _self.grid[swap_info.to_x, swap_info.to_y];
	            _self.grid[swap_info.to_x, swap_info.to_y] = temp;
	        } else {
	            // 🔹 If the board just moved up, apply the swap **one row higher**
	            var temp = grid[swap_info.from_x, swap_info.from_y - 1];
	            _self.grid[swap_info.from_x, swap_info.from_y - 1] = _self.grid[swap_info.to_x, swap_info.to_y - 1];
	            _self.grid[swap_info.to_x, swap_info.to_y - 1] = temp;
	        }

	        // Reset offsets
	        _self.grid[swap_info.from_x, swap_info.from_y].offset_x = 0;
	        _self.grid[swap_info.from_x, swap_info.from_y].offset_y = 0;
	        _self.grid[swap_info.to_x,   swap_info.to_y].offset_x   = 0;
	        _self.grid[swap_info.to_x,   swap_info.to_y].offset_y   = 0;

	        _self.swap_in_progress = false;
	    } else {
	        // Animate the swap
	        var distance = gem_size * swap_info.progress;

	        if (swap_info.from_x < swap_info.to_x) {
	            _self.grid[swap_info.from_x, swap_info.from_y].offset_x =  distance;
	            _self.grid[swap_info.to_x,     swap_info.to_y].offset_x = -distance;
	        } else if (swap_info.from_x > swap_info.to_x) {
	            _self.grid[swap_info.from_x, swap_info.from_y].offset_x = -distance;
	            _self.grid[swap_info.to_x,     swap_info.to_y].offset_x =  distance;
	        }
	        if (swap_info.from_y < swap_info.to_y) {
	            _self.grid[swap_info.from_x, swap_info.from_y].offset_y =  distance;
	            _self.grid[swap_info.to_x,     swap_info.to_y].offset_y = -distance;
	        } else if (swap_info.from_y > swap_info.to_y) {
	            _self.grid[swap_info.from_x, swap_info.from_y].offset_y = -distance;
	            _self.grid[swap_info.to_x,   swap_info.to_y].offset_y   =  distance;
	        }
	    }
	}
}

//if (swap_in_progress) {
//    swap_info.progress += swap_info.speed;

//    //  Check if the swap is happening **mid-shift** (before progress reaches 1)
//    if (swap_info.progress < 1 && global_y_offset == 0) {
//        //  Move swap targets UP by one row since the board just shifted
//        swap_info.from_y -= 1;
//        swap_info.to_y -= 1;
//    }

//    if (swap_info.progress >= 1) {
//        swap_info.progress = 1;

//        // ✅ Ensure the swap happens at the correct row based on whether we just shifted
//        if (global_y_offset != 0) {
//            var temp = grid[swap_info.from_x, swap_info.from_y];
//            grid[swap_info.from_x, swap_info.from_y] = grid[swap_info.to_x, swap_info.to_y];
//            grid[swap_info.to_x, swap_info.to_y] = temp;
//        } else {
//            // 🔹 If the board just moved up, apply the swap **one row higher**
//            var temp = grid[swap_info.from_x, swap_info.from_y - 1];
//            grid[swap_info.from_x, swap_info.from_y - 1] = grid[swap_info.to_x, swap_info.to_y - 1];
//            grid[swap_info.to_x, swap_info.to_y - 1] = temp;
//        }

//        // Reset offsets
//        grid[swap_info.from_x, swap_info.from_y].offset_x = 0;
//        grid[swap_info.from_x, swap_info.from_y].offset_y = 0;
//        grid[swap_info.to_x, swap_info.to_y].offset_x = 0;
//        grid[swap_info.to_x, swap_info.to_y].offset_y = 0;

//        swap_in_progress = false;
//    } else {
//        // Animate the swap
//        var distance = gem_size * swap_info.progress;

//        if (swap_info.from_x < swap_info.to_x) {
//            grid[swap_info.from_x, swap_info.from_y].offset_x =  distance;
//            grid[swap_info.to_x,   swap_info.to_y].offset_x   = -distance;
//        } else if (swap_info.from_x > swap_info.to_x) {
//            grid[swap_info.from_x, swap_info.from_y].offset_x = -distance;
//            grid[swap_info.to_x,   swap_info.to_y].offset_x   =  distance;
//        }
//        if (swap_info.from_y < swap_info.to_y) {
//            grid[swap_info.from_x, swap_info.from_y].offset_y =  distance;
//            grid[swap_info.to_x,   swap_info.to_y].offset_y   = -distance;
//        } else if (swap_info.from_y > swap_info.to_y) {
//            grid[swap_info.from_x, swap_info.from_y].offset_y = -distance;
//            grid[swap_info.to_x,   swap_info.to_y].offset_y   =  distance;
//        }
//    }
//}

function create_swap_info()
{
	var swap_info = 
	{
		from_x: -1, 
		from_y: -1, 
		to_x: -1, 
		to_y: -1,
	    progress: 0, 
		speed: 0.1
	}
	
	return swap_info;
}

// Script Created By DiiAboss AKA Dillon Abotossaway
///@function execute_swap
///
///@description Executes a swap between two gems, handling special cases like shifting and frozen blocks.
///
///@param {struct} _self - The game object managing the board.
///@param {real} ax - The x-coordinate of the first gem.
///@param {real} ay - The y-coordinate of the first gem.
///@param {real} bx - The x-coordinate of the second gem.
///@param {real} by - The y-coordinate of the second gem.
///
function execute_swap(_self, ax, ay, bx, by) {
    var width = _self.width;
    var height = _self.height;

    // ✅ Validate swap positions (ensures within grid bounds)
    if (
        ax < 0 || ax >= width || ay < 0 || ay >= height ||
        bx < 0 || bx >= width || by < 0 || by >= height
    ) return;
	
	if (_self.grid[ax, ay].slime_hp > 0)
	{
		_self.grid[ax, ay].slime_hp -= 1;
	} else
	
		if (_self.grid[bx, by].slime_hp > 0)
	{
		_self.grid[bx, by].slime_hp -= 1;
	} else
	
	{
		// ✅ **If slime HP runs out, return to normal**
		if (_self.grid[ax, ay].slime_hp <= 0) {
		    _self.grid[ax, ay].max_fall_delay = 5;  // ✅ Normal falling speed
		    _self.grid[ax, ay].swap_speed = 0.15;    // ✅ Normal swap speed
		}
		
		// ✅ **If slime HP runs out, return to normal**
		if (_self.grid[bx, by].slime_hp <= 0) {
		    _self.grid[bx, by].max_fall_delay = 5;  // ✅ Normal falling speed
		    _self.grid[bx, by].swap_speed = 0.15;    // ✅ Normal swap speed
		}
	}
	

    // ✅ Prevent swapping if one of the gems is being destroyed
    if (is_being_destroyed(ax, ay) || is_being_destroyed(bx, by)) return;

    // ✅ Prevent swapping frozen blocks
    if (_self.grid[ax, ay].frozen || _self.grid[bx, by].frozen) return;

    // ✅ Prevent swapping MEGA blocks
    if (_self.grid[ax, ay].type == BLOCK.MEGA || _self.grid[bx, by].type == BLOCK.MEGA) return;
	
	var _swap_speed = min(_self.grid[ax, ay].swap_speed, _self.grid[bx, by].swap_speed);

    // 🔹 Handle row shifting logic
    if (_self.global_y_offset == 0) {
        _self.swap_info.from_x = ax;
        _self.swap_info.from_y = ay - 1;  // ✅ Adjusting swap to account for shifting
        _self.swap_info.to_x   = bx;
        _self.swap_info.to_y   = by - 1;
        _self.swap_info.progress = 0;
		_self.swap_info.speed = _swap_speed;
    }
    else
    {
        _self.swap_in_progress = true;
        _self.swap_info.from_x = ax;
        _self.swap_info.from_y = ay;
        _self.swap_info.to_x   = bx;
        _self.swap_info.to_y   = by;
        _self.swap_info.progress = 0;
        _self.swap_info.speed = _swap_speed;
    }
}
