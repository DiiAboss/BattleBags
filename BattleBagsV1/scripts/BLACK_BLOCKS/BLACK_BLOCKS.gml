function check_adjacent_black_blocks(_self, _x, _y, _list) {
    var directions = [
        [-1, 0], [1, 0], [0, -1], [0, 1], // Left, Right, Up, Down
        [-1, -1], [1, -1], [-1, 1], [1, 1] // Diagonal directions
    ];

    for (var i = 0; i < array_length(directions); i++) {
        var dx = _x + directions[i][0];
        var dy = _y + directions[i][1];

        if (dx >= 0 && dx < _self.width && dy >= 0 && dy < _self.height) {
            var gem = _self.grid[dx, dy];
            if (gem.type == BLOCK.BLACK) {
                gem.popping = true;
            }
        }
    }
}

function transform_black_blocks(_self, _list) {
    for (var i = 0; i < ds_list_size(_list); i++) {
        var pos = ds_list_find_value(_list, i);
        var _x = pos[0];
        var _y = pos[1];
		
        // ✅ Transform into a random new block
        
    }
}

function update_black_blocks(_self, _list) {
    for (var i = 0; i < _self.width; i++) {
        for (var j = 0; j < _self.height; j++) {
            var gem = _self.grid[i, j];

            if (gem.type == BLOCK.BLACK && gem.popping) {
                gem.pop_timer--;

                if (gem.pop_timer <= 0) {
                    // 🔥 **Transform black block into something else**
                    _self.grid[i, j] = create_gem(irandom_range(0, _self.numberOfGemTypes - 1));
                    gem.popping = false; // Stop the popping effect
                }
            }
        }
    }
}