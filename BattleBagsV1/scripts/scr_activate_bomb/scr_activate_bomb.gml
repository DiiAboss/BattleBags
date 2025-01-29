function activate_bomb_gem(_self, _x, _y) {
    for (var i = _x - 1; i <= _x + 1; i++) {
        for (var j = _y - 1; j <= _y + 1; j++) {
            if (i >= 0 && i < _self.width && j >= 0 && j < _self.height && _self.grid[i, j] != -1) {
                destroy_block(i, j);
            }
        }
    }
}