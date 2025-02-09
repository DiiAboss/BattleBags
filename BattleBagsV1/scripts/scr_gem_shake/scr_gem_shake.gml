function gem_shake(_self, shake_amount = 8)
{
	var width = _self.width;
	var height = _self.height;
	
	for (var i = 0; i < width; i++) {
	    for (var j = 0; j < height; j++) {
	        var gem = _self.grid[i, j];
			
			if (gem.x_scale > 1)
			{
				gem.x_scale -= 0.005;
			}
			else
			{
				gem.x_scale += 0.005;
			}

			if (gem.y_scale > 1)
			{
				gem.y_scale += 0.005;
			}
			else
			{
				gem.y_scale += 0.005;
			}

	        if (gem.type != -1 && gem.shake_timer > 0) {
	            gem.shake_timer--;

	            // Apply shaking effect by setting offset_x and offset_y
	            gem.offset_x = irandom_range(-shake_amount, shake_amount); // Shake horizontally
	            gem.offset_y = irandom_range(-shake_amount, shake_amount); // Shake vertically
	        } else {
	            // Reset offset when not shaking
	            gem.offset_x = 0;
	            gem.offset_y = 0;
	        }
	    }
	}
}