function check_adjacent_black_blocks(_self, _x, _y, _list) {
    var directions = [
        [-1, 0], [1, 0], [0, -1], [0, 1] // Left, Right, Up, Down
    ];

    for (var i = 0; i < array_length(directions); i++) {
        var dx = _x + directions[i][0];
        var dy = _y + directions[i][1];

        if (dx >= 0 && dx < _self.width && dy >= 0 && dy < _self.height) {
            var gem = _self.grid[dx, dy];
            if (gem.type == BLOCK.BLACK) {
                ds_list_add(_list, [dx, dy]); // ✅ Store positions of black blocks
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
    for (var i = 0; i < ds_list_size(_list); i++) {
        var pos = ds_list_find_value(_list, i);
        var _x = pos[0];
        var _y = pos[1];

        var gem = _self.grid[_x, _y];

        if (gem.type == BLOCK.BLACK) {
            // ✅ Transform into a new gem (use BLOCK.RANDOM for variety)
            _self.grid[_x, _y] = create_gem(BLOCK.RANDOM);
        }
    }
}
