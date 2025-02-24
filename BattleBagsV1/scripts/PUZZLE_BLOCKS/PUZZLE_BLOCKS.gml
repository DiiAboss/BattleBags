function create_puzzle_gem(_type, _group_id, _img_number) {
    var gem = create_block(_type);
    gem.group_id = _group_id;
    gem.img_number = _img_number;
    return gem;
}
	
function spawn_puzzle_blocks(_self) {
    var width = _self.width;
    var height = _self.height;
    
    // ✅ Store 4 unique positions
    var random_pos_array = [];

    while (array_length(random_pos_array) < 4) {
        var start_x = irandom_range(0, width - 1);
        var start_y = irandom_range(0, height - 1);
        var position = [start_x, start_y];

        // 🔹 Ensure position is unique
        var is_duplicate = false;
        for (var i = 0; i < array_length(random_pos_array); i++) {
            if (random_pos_array[i][0] == start_x && random_pos_array[i][1] == start_y) {
                is_duplicate = true;
                break;
            }
        }

        if (!is_duplicate && _self.grid[start_x, start_y].type != BLOCK.PUZZLE_1) {
            array_push(random_pos_array, position);
        }
    }

    // ✅ Generate unique group_id
    var group_id = irandom_range(1, 999999);

    // ✅ Assign the puzzle gems using the unique positions
    for (var i = 0; i < 4; i++) {
        var _x = random_pos_array[i][0];
        var _y = random_pos_array[i][1];

        _self.grid[_x, _y] = create_puzzle_gem(BLOCK.PUZZLE_1, group_id, i);
    }

    return true;
}

function check_puzzle_match(_self, _x, _y) {
    // ✅ Bounds check (to avoid out-of-grid errors)
    if (_x < 0 || _x >= _self.width - 1 || _y < 0 || _y >= _self.height - 1) return false;

    // ✅ Retrieve 4 adjacent blocks
    var gem_0 = _self.grid[_x, _y];         // Top-left
    var gem_1 = _self.grid[_x + 1, _y];     // Top-right
    var gem_2 = _self.grid[_x, _y + 1];     // Bottom-left
    var gem_3 = _self.grid[_x + 1, _y + 1]; // Bottom-right

    // ✅ Check if all blocks are `BLOCK.PUZZLE_1`
    if (gem_0.type != BLOCK.PUZZLE_1 || gem_1.type != BLOCK.PUZZLE_1 ||
        gem_2.type != BLOCK.PUZZLE_1 || gem_3.type != BLOCK.PUZZLE_1) {
        return false;
    }


    // ✅ Ensure they match the correct `img_number` pattern
    if (gem_0.img_number == 0 && gem_1.img_number == 1 &&
        gem_2.img_number == 2 && gem_3.img_number == 3) {
        return true; // ✅ Match Found!
    }

    return false; // ❌ No match
}

function find_all_puzzle_matches(_self) {
    for (var _x = 0; _x < _self.width - 1; _x++) {
        for (var _y = 0; _y < _self.height - 1; _y++) {
            if (check_puzzle_match(_self, _x, _y)) {
                // ✅ Trigger match event (Destroy, transform, etc.)
                handle_puzzle_match(_self, _x, _y);
            }
        }
    }
}


function handle_puzzle_match(_self, _x, _y) {
    // ✅ Retrieve the matched blocks
    var gem_0 = _self.grid[_x, _y];
    var gem_1 = _self.grid[_x + 1, _y];
    var gem_2 = _self.grid[_x, _y + 1];
    var gem_3 = _self.grid[_x + 1, _y + 1];
	
	var _start_delay = 20;
	var dx = _x - global.lastSwapX;
	var dy = _y - global.lastSwapY;
	var dist = sqrt(dx * dx + dy * dy);
    // ✅ Mark blocks for destruction
    gem_0.popping = true;
    gem_1.popping = true;
    gem_2.popping = true;
    gem_3.popping = true;
	
    // ✅ Send the block to pop_list (Now applies to normal and transformed blocks)
	var pop_info = {
	    x: _x,
	    y: _y,
	    gem_type: gem_0.type,
	    timer: 0,
	    start_delay: dist * _start_delay, // Wave effect
	    scale: 1.0,
	    popping: true,
	    powerup: gem_0.powerup,
	    dir: gem_0.dir,
	    offset_x: gem_0.offset_x,
	    offset_y: gem_0.offset_y,
	    color: gem_0.color,
	    y_offset_global: global_y_offset,
	    match_size: 1, // ✅ Store the match size
	    match_points: 1,
	    bomb_tracker: false, // Flag to mark this pop as bomb‐generated
	    bomb_level: 0,
		img_number: gem_0.img_number,
        is_big: false,
	};

	_self.grid[_x, _y].popping   = true;
	_self.grid[_x, _y].pop_timer = dist * _start_delay;
	ds_list_add(global.pop_list, pop_info);
	
		var pop_info = {
	    x: _x + 1,
	    y: _y,
	    gem_type: gem_1.type,
	    timer: 0,
	    start_delay: dist * _start_delay, // Wave effect
	    scale: 1.0,
	    popping: true,
	    powerup: gem_1.powerup,
	    dir: gem_1.dir,
	    offset_x: gem_1.offset_x,
	    offset_y: gem_1.offset_y,
	    color: gem_1.color,
	    y_offset_global: global_y_offset,
	    match_size: 1, // ✅ Store the match size
	    match_points: 1,
	    bomb_tracker: false, // Flag to mark this pop as bomb‐generated
	    bomb_level: 0,
		img_number: gem_1.img_number,
            is_big: false,
	};
		_self.grid[_x + 1, _y].popping   = true;	
	_self.grid[_x + 1, _y].pop_timer = dist * _start_delay;
	ds_list_add(global.pop_list, pop_info);
	
		var pop_info = {
	    x: _x,
	    y: _y + 1,
	    gem_type: gem_2.type,
	    timer: 0,
	    start_delay: dist * _start_delay, // Wave effect
	    scale: 1.0,
	    popping: true,
	    powerup: gem_2.powerup,
	    dir: gem_2.dir,
	    offset_x: gem_2.offset_x,
	    offset_y: gem_2.offset_y,
	    color: gem_2.color,
	    y_offset_global: global_y_offset,
	    match_size: 1, // ✅ Store the match size
	    match_points: 1,
	    bomb_tracker: false, // Flag to mark this pop as bomb‐generated
	    bomb_level: 0,
		img_number: gem_2.img_number,
            is_big: false,
	};
		_self.grid[_x, _y + 1].popping   = true;
	_self.grid[_x, _y + 1].pop_timer = dist * _start_delay;
	ds_list_add(global.pop_list, pop_info);
	
		var pop_info = {
	    x: _x + 1,
	    y: _y + 1,
	    gem_type: gem_3.type,
	    timer: 0,
	    start_delay: dist * _start_delay, // Wave effect
	    scale: 1.0,
	    popping: true,
	    powerup: gem_3.powerup,
	    dir: gem_3.dir,
	    offset_x: gem_3.offset_x,
	    offset_y: gem_3.offset_y,
	    color: gem_3.color,
	    y_offset_global: global_y_offset,
	    match_size: 1, // ✅ Store the match size
	    match_points: 1,
	    bomb_tracker: false, // Flag to mark this pop as bomb‐generated
	    bomb_level: 0,
		img_number: gem_3.img_number,
            is_big: false,
	};
		_self.grid[_x + 1, _y + 1].popping   = true;	
	_self.grid[_x + 1, _y + 1].pop_timer = dist * _start_delay;
ds_list_add(global.pop_list, pop_info);


	destroy_block(self, _x, + 1, _y + 1);
	destroy_block(self, _x, _y);
	destroy_block(self, _x, _y + 1);
	destroy_block(self, _x + 1, _y);
}

