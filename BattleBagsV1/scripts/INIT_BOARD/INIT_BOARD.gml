function initialize_game_board(_self, width = 8, height = 16, spawn_row = 6)
{
	
	_self.grid = array_create(width);
	
	
	for (var i = 0; i < width; i++) {
		_self.grid[i] = array_create(height);
		for (var j = 0; j < height; j++) {
			_self.grid[i][j] = create_gem(BLOCK.NONE); // Initialize all cells as empty
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
	// Initial Gem Spawn Rows
	// ------------------------------------------------------
	_self.locked = array_create(width);
	for (var i = 0; i < width; i++) {
	    _self.locked[i] = array_create(height, false);
	}

	
	_self.spawn_rows = min(spawn_row, height);
	for (var i = 0; i < width; i++) {
	    for (var j = height - spawn_row; j < height; j++) {
	        _self.grid[i][j] = create_gem(BLOCK.RANDOM);
	    }
	}

	// Ensure the entire grid is valid
	for (var i = 0; i < width; i++) {
	    for (var j = 0; j < height; j++) {
	        if (is_undefined(_self.grid[i][j]) || !is_struct(_self.grid[i][j])) {
	            _self.grid[i][j] = create_gem(BLOCK.NONE);
	        }
	    }
	}
}