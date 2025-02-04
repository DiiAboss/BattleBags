function add_new_column(_self) {
    var old_width = array_length(_self.grid);
    var new_width = old_width + 1;
    var height = array_length(_self.grid[0]);

    // ✅ Step 1: Create a new grid with the new width
    var new_grid = array_create(new_width);
    
    for (var i = 0; i < new_width; i++) {
        new_grid[i] = array_create(height);
        
        for (var j = 0; j < height; j++) {
            if (i < old_width) {
                // ✅ Copy existing columns
                new_grid[i][j] = _self.grid[i][j];
            } else {
                // ✅ Initialize new column with empty gems
                new_grid[i][j] = create_gem(BLOCK.NONE);
            }
        }
    }

    // ✅ Step 2: Replace old grid with the new expanded grid
    _self.grid = new_grid;

    // ✅ Step 3: Expand gem offset arrays
    _self.gem_x_offsets = array_create(new_width);
    _self.gem_y_offsets = array_create(new_width);

    for (var i = 0; i < new_width; i++) {
        _self.gem_x_offsets[i] = array_create(height, 0);
        _self.gem_y_offsets[i] = array_create(height, 0);
    }

    // ✅ Step 4: Expand lock array (if used)
    _self.locked = array_create(new_width);
    for (var i = 0; i < new_width; i++) {
        _self.locked[i] = array_create(height, false);
    }

    // ✅ Step 5: Update width
    _self.width = new_width;
}