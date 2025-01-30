function update_freeze_timer(_self)
{
	var gem_size = _self.gem_size;
	var height   = _self.height;
	var width    = _self.width;
	
	for (var i = 0; i < width; i++) {
	    for (var j = 0; j < height; j++) {
	        var gem = _self.grid[i, j];
			// 1) Compute the pixel position for the new object
				    var _x = (i * gem_size) + _self.board_x_offset + _self.offset;
				    var _y = (j * gem_size) + _self.offset + _self.global_y_offset + _self.gem_y_offsets[i, j];
	        // ❄️ If frozen, countdown the freeze timer
	        if (gem.frozen) {
	            gem.freeze_timer--;

	            // 🔥 Thaw when timer reaches 0
	            if (gem.freeze_timer <= 0) {
	                gem.frozen = false;
					effect_create_depth(depth - 1, ef_spark, _x, _y, 1, c_blue);
					effect_create_depth(depth - 1, ef_firework, _x, _y, 0.5, c_white);
	            }
	        }
	    }
	}
}