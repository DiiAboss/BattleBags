
function check_adjacent_black_blocks(_self, _x, _y, _list, pop_all_adjacent_black_blocks = true) {
    var directions = [
        [-1, 0], [1, 0], [0, -1], [0, 1] // Left, Right, Up, Down
    ];

    for (var i = 0; i < array_length(directions); i++) {
        var dx = _x + directions[i][0];
        var dy = _y + directions[i][1];

        if (dx >= 0 && dx < _self.width && dy >= 0 && dy < _self.height) {
            var gem = _self.grid[dx, dy];
            if (gem.popping)
            {
                _self.grid[_x, _y] = create_block(BLOCK.RANDOM);
            }

            //if (gem.type == BLOCK.BLACK) {
                //if (!ds_list_find_index(_list, [dx, dy])) { // Avoid duplicates
                    //ds_list_add(_list, [dx, dy]); // ✅ Store positions of black blocks
                //}
            //}
        }
    }
}

function pop_adjacent_black_blocks(_self, gem_x, gem_y) {
    
    var gem = _self.grid[gem_x, gem_y]
    
    if (gem.type == BLOCK.BLACK) 
    {
        var directions = [
            [-1, 0], [1, 0], [0, -1], [0, 1] // Left, Right, Up, Down
        ];
    
        for (var i = 0; i < array_length(directions); i++) {
            var dx = gem_x + directions[i][0];
            var dy = gem_y + directions[i][1];
    
            if (dx >= 0 && dx < _self.board_width && dy >= 0 && dy < _self.board_height) {
                var gem = _self.grid[dx, dy];
                if (gem.popping)
                {
                    _self.grid[gem_x, gem_y] = create_block(BLOCK.RANDOM);
                    // 🔥 **Create a pop effect**
                    var draw_x = (gem_x * 64) + _self.board_x_offset + 32;
                    var draw_y = (gem_y * 64) + _self.global_y_offset + 32;
                    effect_create_above(ef_firework, draw_x, draw_y, 1, c_red);
                    effect_create_above(ef_smokeup, draw_x, draw_y, 1, c_red);
                }
            }
        }
    }
}



function update_black_blocks(_self, _list) {
    for (var i = 0; i < ds_list_size(_list); i++) {
        var pos = ds_list_find_value(_list, i);
        var _x = pos[0];
        var _y = pos[1];

        var gem = _self.grid[_x, _y];

        if (gem.type == BLOCK.BLACK) {
            // ✅ Transform into a new gem (use BLOCK.RANDOM for variety)
            _self.grid[_x, _y] = create_block(BLOCK.RANDOM);
        }
    }
}
