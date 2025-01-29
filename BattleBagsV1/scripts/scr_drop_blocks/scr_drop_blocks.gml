function drop_blocks(_self, fall_speed = 2) {
    var width = _self.width;
    var height = _self.height;
    var gem_size = _self.gem_size;

    for (var j = height - 2; j >= 0; j--) { // Process from bottom-up
        for (var i = 0; i < width; i++) {
            var gem = _self.grid[i, j];

            if (gem.type != -1) { // Valid gem
                var below = _self.grid[i, j + 1];

                // ✅ If there's an empty space below, start falling
                if (below.type == -1) {
                    // ✅ Countdown the fall delay before moving
                    if (gem.fall_delay > 0) {
                        gem.fall_delay--;
                    } else {
                        // ✅ Move the gem **one row down**
                        _self.grid[i, j + 1] = gem;
                        _self.grid[i, j] = create_gem(-1); // Clear old position
                        _self.gem_y_offsets[i, j + 1] = _self.gem_y_offsets[i, j]; // Keep offset
                        _self.gem_y_offsets[i, j] = 0; // Reset previous position
                        
                        // ✅ Reset fall delay
                        gem.fall_delay = 10;
                    }
                }
            }
        }
    }
}
