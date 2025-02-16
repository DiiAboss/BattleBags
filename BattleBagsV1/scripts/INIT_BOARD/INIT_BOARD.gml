// Script Created By DiiAboss AKA Dillon Abotossaway
///@function initialize_game_board
///
///@description Initializes the game board with buffer zones at the top and bottom.
///
///@param {struct} _self - The game object managing the grid.
///@param {real} width - Number of columns in the grid.
///@param {real} height - Total number of rows (including buffer).
///@param {real} spawn_row - Number of initial rows to spawn.
///
function initialize_game_board(_self, width = 8, height = 24, spawn_row = 6) 
{
    // ✅ Create the grid as a 2D array
    _self.grid = array_create(width);
    
    for (var i = 0; i < width; i++) {
        _self.grid[i] = array_create(height);
        for (var j = 0; j < height; j++) {
            _self.grid[i][j] = create_block(BLOCK.NONE); // Initialize all cells as empty
        }
    }

    // ------------------------------------------------------
    // Create Gem Offset Arrays
    // ------------------------------------------------------
    _self.gem_x_offsets = array_create(width);
    _self.gem_y_offsets = array_create(width);

    for (var i = 0; i < width; i++) {
        _self.gem_x_offsets[i] = array_create(height, 0);
        _self.gem_y_offsets[i] = array_create(height, 0);
    }

    // ------------------------------------------------------
    // Initial Gem Spawn Rows (Inside Playable Area)
    // ------------------------------------------------------
    _self.locked = array_create(width);
    for (var i = 0; i < width; i++) {
        _self.locked[i] = array_create(height, false);
    }

    // ✅ New Spawning Logic (Inside Playable Area: Rows 4 to 16)
    _self.spawn_rows += top_playable_row;
    for (var i = 0; i < width; i++) {
        for (var j = bottom_playable_row - _self.spawn_rows; j < height; j++) {
            _self.grid[i][j] = create_block(BLOCK.RANDOM);
        }
    }

    // ✅ Ensure the entire grid is valid
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            if (is_undefined(_self.grid[i][j]) || !is_struct(_self.grid[i][j])) {
                _self.grid[i][j] = create_block(BLOCK.NONE);
            }
        }
    }
}


function create_grid_array(width = 8, height = 24)
{
    var grid = array_create(width);
    
    for (var i = 0; i < width; i++) {
        grid[i] = array_create(height);
        for (var j = 0; j < height; j++) {
            grid[i][j] = create_block(BLOCK.NONE); // Initialize all cells as empty
        }
    }
    
    return grid;
}


function spawn_random_blocks_in_array(_array, spawn_rows_from_bottom)
{
    var width = array_length(_array);
    var height = array_length(_array[0]); // ✅ Fix height calculation
    
    for (var i = 0; i < width; i++) {
        for (var j = height - 1; j >= 12; j--) { // ✅ Fix index bounds
            _array[i][j] = create_block(BLOCK.RANDOM);
        }
    }
    
    return _array;
}


