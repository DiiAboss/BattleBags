function add_new_column(player) {
    var old_width = array_length(player.grid);
    var new_width = old_width + 1;
    var height = array_length(player.grid[0]);

    // ✅ Step 1: Create a new grid with the new width
    var new_grid = array_create(new_width);
    
    for (var i = 0; i < new_width; i++) {
        new_grid[i] = array_create(height);
        
        for (var j = 0; j < height; j++) {
            if (i < old_width) {
                // ✅ Copy existing columns
                new_grid[i][j] = player.grid[i][j];
            } else {
                // ✅ Initialize new column with empty gems
                new_grid[i][j] = create_block(BLOCK.NONE);
            }
        }
    }

    // ✅ Step 2: Replace old grid with the new expanded grid
    player.grid = new_grid;

    // ✅ Step 3: Expand gem offset arrays
    player.gem_x_offsets = array_create(new_width);
    player.gem_y_offsets = array_create(new_width);

    for (var i = 0; i < new_width; i++) {
        player.gem_x_offsets[i] = array_create(height, 0);
        player.gem_y_offsets[i] = array_create(height, 0);
    }

    // ✅ Step 4: Expand lock array (if used)
    player.locked = array_create(new_width);
    for (var i = 0; i < new_width; i++) {
        player.locked[i] = array_create(height, false);
    }

    // ✅ Step 5: Update width
    player.board_width = new_width;
}