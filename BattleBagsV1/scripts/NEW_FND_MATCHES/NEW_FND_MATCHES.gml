// Script Created By DiiAboss AKA Dillon Abotossaway
// Refactored for improved modularity and clarity

///@function find_and_destroy_matches
///
///@description Finds and removes matches of 3+ in the grid, including horizontal, vertical, and diagonal matches.
///
///@param {id} _self - The game object managing the board.
///@return {bool} - Returns `true` if any matches were found.
function new_find_and_destroy_matches(_self) {
    var width = _self.width;
    var bottom_row = _self.bottom_playable_row;
    var found_any = false;
    var first_found = false; // Track the first block in the combo
    var total_match_points = 0; // Accumulates points for multiple matches
    
    // Create a data structure to track black blocks for transformation
    global.black_blocks_to_transform = ds_list_create();
    
    // Check for 2x2 matches
    check_2x2_match(_self);
    
    // Initialize the marked_for_removal array
    var marked_for_removal = initialize_removal_grid(_self, width, bottom_row);
    
    // Check for horizontal matches
    var horizontal_results = find_horizontal_matches(_self, width, bottom_row, marked_for_removal);
    marked_for_removal = horizontal_results.marked_grid;
    total_match_points += horizontal_results.points;
    if (!first_found && horizontal_results.found_match) {
        combo_x = horizontal_results.first_match_x;
        combo_y = horizontal_results.first_match_y;
        first_found = true;
    }
    
    // Check for vertical matches
    var vertical_results = find_vertical_matches(_self, width, bottom_row, marked_for_removal);
    marked_for_removal = vertical_results.marked_grid;
    total_match_points += vertical_results.points;
    if (!first_found && vertical_results.found_match) {
        combo_x = vertical_results.first_match_x;
        combo_y = vertical_results.first_match_y;
        first_found = true;
    }
    
    // Check for diagonal matches if enabled
    diagonal_match_process(_self, _self.diagonal_matches);
    
    // Process the marked blocks
    found_any = process_matched_blocks(_self, width, bottom_row, marked_for_removal, total_match_points);
    
    return found_any;
}

///@function initialize_removal_grid
///
///@description Initializes the grid that tracks which blocks are marked for removal
///
///@param {any} _self - The game object managing the board.
///@param {real} width - Width of the grid
///@param {real} bottom_row - Index of the bottom playable row
///@return - The initialized marked_for_removal grid
function initialize_removal_grid(_self, width, bottom_row) {
    var marked_for_removal = array_create(width, bottom_row);
    
    for (var xx = 0; xx < width; xx++) {
        for (var yy = 0; yy <= bottom_row; yy++) {
            marked_for_removal[xx, yy] = false;
            
            // Handle shake timer and popping state
            if (_self.grid[xx, yy].shake_timer > 0) {
                _self.grid[xx, yy].popping = true;
            } else {
                _self.grid[xx, yy].popping = false;
            }
        }
    }
    
    return marked_for_removal;
}



///@function find_horizontal_matches
///
///@description Finds horizontal matches of 3+ in the grid
///
///@param {id} _self - The game object managing the board.
///@param {real} width - Width of the grid
///@param {real} bottom_row - Index of the bottom playable row
///@param {array} marked_grid - The grid tracking marked blocks
///@return {struct} - Contains updated marked grid, points, and first match info
function find_horizontal_matches(_self, width, bottom_row, marked_grid) {
    var total_points = 0;
    var found_match = false;
    var first_match_x = 0;
    var first_match_y = 0;
    var black_blocks_to_transform = ds_list_create();
    
    for (var j = 0; j <= bottom_row; j++) {
        var match_count = 1;
        var start_idx = 0;

        for (var i = 1; i < width; i++) {
            if (can_match(_self.grid[i, j], _self.grid[i - 1, j])) {
                if (match_count == 1) start_idx = i - 1;
                match_count++;
            } else {
                if (match_count >= 3) {
                    for (var k = 0; k < match_count; k++) {
                        var xx = start_idx + k;
                        if (xx >= 0 && xx < width) {
                            marked_grid[xx, j] = true;

                            if (!found_match) {
                                first_match_x = xx;
                                first_match_y = j;
                                found_match = true;
                            }
                            
                            // Check for adjacent black blocks
                            check_adjacent_black_blocks(_self, j, xx, black_blocks_to_transform);
                        }
                    }
                    // Add points based on match size
                    total_points += calculate_match_points(_self, match_count);
                }
                match_count = 1;
            }
        }
        
        // Check for matches at the end of rows
        if (match_count >= 3) {
            for (var k = 0; k < match_count; k++) {
                var xx = start_idx + k;
                if (xx >= 0 && xx < width) {
                    marked_grid[xx, j] = true;

                    if (!found_match) {
                        first_match_x = xx;
                        first_match_y = j;
                        found_match = true;
                    }
                    
                    // Check for adjacent black blocks
                    check_adjacent_black_blocks(_self, j, xx, black_blocks_to_transform);
                }
            }
            total_points += calculate_match_points(_self, match_count);
        }
    }
    
    ds_list_destroy(black_blocks_to_transform);
    
    return {
        marked_grid: marked_grid,
        points: total_points,
        found_match: found_match,
        first_match_x: first_match_x,
        first_match_y: first_match_y
    };
}



///@function find_vertical_matches
///
///@description Finds vertical matches of 3+ in the grid
///
///@param {id} _self - The game object managing the board.
///@param {real} width - Width of the grid
///@param {real} bottom_row - Index of the bottom playable row
///@param {array} marked_grid - The grid tracking marked blocks
///@return {struct} - Contains updated marked grid, points, and first match info
function find_vertical_matches(_self, width, bottom_row, marked_grid) {
    var total_points = 0;
    var found_match = false;
    var first_match_x = 0;
    var first_match_y = 0;
    var black_blocks_to_transform = ds_list_create();
    
    for (var i = 0; i < width; i++) {
        var match_count = 1;
        var start_idx = 0;

        for (var j = 1; j <= bottom_row; j++) {
            if (can_match(_self.grid[i, j], _self.grid[i, j - 1])) {
                if (match_count == 1) start_idx = j - 1;
                match_count++;
            } else {
                if (match_count >= 3) {
                    for (var k = 0; k < match_count; k++) {
                        var yy = start_idx + k;
                        
                        if (yy >= 0 && yy <= bottom_row) {
                            marked_grid[i, yy] = true;

                            if (!found_match) {
                                first_match_x = i;
                                first_match_y = yy;
                                found_match = true;
                            }
                            
                            // Check for adjacent black blocks
                            check_adjacent_black_blocks(_self, i, yy, black_blocks_to_transform);
                        }
                    }
                    total_points += calculate_match_points(_self, match_count);
                }
                match_count = 1;
            }
        }
        
        // Check for matches at the bottom of columns
        if (match_count >= 3) {
            for (var k = 0; k < match_count; k++) {
                var yy = start_idx + k;
                if (yy >= 0 && yy <= bottom_row) {
                    marked_grid[i, yy] = true;

                    if (!found_match) {
                        first_match_x = i;
                        first_match_y = yy;
                        found_match = true;
                    }
                    
                    // Check for adjacent black blocks
                    check_adjacent_black_blocks(_self, i, yy, black_blocks_to_transform);
                }
            }
            total_points += calculate_match_points(_self, match_count);
        }
    }
    
    ds_list_destroy(black_blocks_to_transform);
    
    return {
        marked_grid: marked_grid,
        points: total_points,
        found_match: found_match,
        first_match_x: first_match_x,
        first_match_y: first_match_y
    };
}



///@function process_matched_blocks
///
///@description Processes all matched blocks for removal and animations
///
///@param {id} _self - The game object managing the board.
///@param {real} width - Width of the grid
///@param {real} bottom_row - Index of the bottom playable row
///@param {array} marked_for_removal - Grid marking which blocks to remove
///@param {real} total_match_points - Total points from matches
///@return {bool} - Whether any matches were found
function process_matched_blocks(_self, width, bottom_row, marked_for_removal, total_match_points) {
    var found_any = false;
    
    for (var i = 0; i < width; i++) {
        for (var j = 0; j <= bottom_row; j++) {
            if (marked_for_removal[i, j]) {
                found_any = true;
                
                // Apply shake effect
                _self.grid[i, j].shake_timer = _self.max_shake_timer;
                
                var gem = _self.grid[i, j];
                
                // Calculate delay based on distance from last swap
                var dx = i - global.lastSwapX;
                var dy = j - global.lastSwapY;
                var dist = sqrt(dx * dx + dy * dy);
                var _start_delay = (gem.type == BLOCK.BLACK) ? 5 : 5; // Longer delay for black blocks
                
                // Handle big blocks
                if (gem.is_big) {
                    process_big_block(_self, gem, width, bottom_row, dist, _start_delay, total_match_points);
                }
                
                // Add the block to pop list
                add_block_to_pop_list(_self, i, j, gem, dist, _start_delay, total_match_points);
            }
        }
    }
    
    return found_any;
}




///@function process_big_block
///
///@description Processes a big block for removal
///
///@param {id} _self - The game object managing the board.
///@param {id} gem - The gem/block to process
///@param {real} width - Width of the grid
///@param {real} bottom_row - Index of the bottom playable row
///@param {real} dist - Distance from last swap
///@param {real} _start_delay - Base delay for animations
///@param {real} total_match_points - Total points from matches
function process_big_block(_self, gem, width, bottom_row, dist, _start_delay, total_match_points) {
    var group_id = gem.group_id;
    
    for (var _x = 0; _x < width; _x++) {
        for (var _y = 0; _y <= bottom_row; _y++) {
            var other_gem = _self.grid[_x, _y];
            
            if (other_gem.group_id == group_id) {
                // Convert each big block part into a small block of the same type
                _self.grid[_x, _y] = create_block(gem.type);
                
                // Create pop info for this part
                var pop_info = {
                    x: _x,
                    y: _y,
                    gem_type: gem.type,
                    timer: 0,
                    start_delay: dist * _start_delay,
                    scale: 1.0,
                    popping: true,
                    powerup: gem.powerup,
                    dir: gem.dir,
                    offset_x: gem.offset_x,
                    offset_y: gem.offset_y,
                    color: gem.color,
                    y_offset_global: _self.global_y_offset,
                    match_size: 0, // This will be set properly
                    match_points: total_match_points * 1.5,
                    bomb_tracker: false,
                    bomb_level: 0,
                    img_number: gem.img_number,
                    is_big: true,
                };
                
                // Apply popping state and animation
                _self.grid[_x, _y].popping = true;
                _self.grid[_x, _y].pop_timer = dist * _start_delay;
                
                // Play sound effect
                var _pitch = clamp(0.75 + (0.2 * _self.combo), 0.5, 5);
                if (!(_self.game_over_state)) {
                    audio_play_sound(snd_pre_bubble_pop_test, 10, false, 0.25, 0, _pitch);
                }
                
                ds_list_add(global.pop_list, pop_info);
            }
        }
    }
}



///@function add_block_to_pop_list
///
///@description Adds a block to the pop list for animation and removal
///
///@param {id} _self - The game object managing the board.
///@param {real} i - X coordinate in grid
///@param {real} j - Y coordinate in grid
///@param {id} gem - The gem/block to process
///@param {real} dist - Distance from last swap
///@param {real} _start_delay - Base delay for animations
///@param {real} total_match_points - Total points from matches
function add_block_to_pop_list(_self, i, j, gem, dist, _start_delay, total_match_points) {
    var pop_info = {
        x: i,
        y: j,
        gem_type: gem.type,
        timer: 0,
        start_delay: dist * _start_delay,
        scale: 1.0,
        popping: true,
        powerup: gem.powerup,
        dir: gem.dir,
        offset_x: gem.offset_x,
        offset_y: gem.offset_y,
        color: gem.color,
        y_offset_global: _self.global_y_offset,
        match_size: 0, // This will be set properly
        match_points: total_match_points,
        bomb_tracker: false,
        bomb_level: 0,
        img_number: gem.img_number,
        is_big: false,
    };
    
    // Apply popping state and animation
    _self.grid[i, j].popping = true;
    _self.grid[i, j].pop_timer = dist * _start_delay;
    
    // Play sound effect
    var _pitch = clamp(1 + (0.2 * _self.combo), 0.5, 5);
    if (!(_self.game_over_state)) {
        audio_play_sound(snd_pre_bubble_pop_test, 10, false, 0.25, 0, _pitch);
    }
    
    ds_list_add(global.pop_list, pop_info);
}