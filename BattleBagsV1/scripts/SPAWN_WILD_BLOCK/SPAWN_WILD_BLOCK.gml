function spawn_wild_block(_self, multiplier = 1) {
    var _rand_array = array_create(0); // Stores valid positions

    // ✅ Find valid positions for wild blocks
    for (var j = 0; j < _self.height; j++) {
        for (var i = 0; i < _self.width; i++) {
            if (_self.grid[i, j].type != -1) { // Only non-empty slots
                array_push(_rand_array, { x: i, y: j }); // ✅ Store x, y coordinates
            }
        }
    }

    // ✅ Ensure there's at least one valid position
    if (array_length(_rand_array) > 0) {
        for (var k = 0; k < multiplier; k++) { // ✅ Add multiplier functionality
            var _rand_index = irandom(array_length(_rand_array) - 1);
            var _rand_pos = _rand_array[_rand_index];

            // ✅ Change the block at the random position to WILD
            _self.grid[_rand_pos.x, _rand_pos.y].type = BLOCK.WILD;
        }
    }
}