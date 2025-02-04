function activate_shuffle(_self) {
	
	var width = _self.width;
	var height = _self.height;
	
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            if (_self.grid[i, j] != -1) {
                _self.grid[i, j] = create_gem(BLOCK.RANDOM);
            }
        }
    }
}