function mouse_dragged(_self, pointer_x = mouse_x, pointer_y = mouse_y) {
	
	var input = _self.input;
	
	var width = _self.width;
	var height = _self.height;
	var board_x_offset = _self.board_x_offset;
	var gem_size = _self.gem_size;
	var global_y_offset = _self.global_y_offset;
	
	    // 🔹 Convert mouse coordinates to grid indices
    var hover_x = floor((pointer_x - board_x_offset) / gem_size);
    var hover_y = floor((pointer_y - global_y_offset) / gem_size);
	
	// ✅ Store hovered block for **drawing**
	if (hover_x >= 0 && hover_x < width && hover_y >= 0 && hover_y < height) {
	    _self.hovered_block = [hover_x, hover_y]; // Store for later use
	} else {
	    _self.hovered_block = [-1, -1]; // Reset if out of bounds
	}
	
    // When the left mouse button is pressed, record the starting cell
    if (mouse_check_button_pressed(mb_left)) {
        // Convert mouse coordinates to grid indices
        _self.selected_x = hover_x;
        _self.selected_y = hover_y;
		
		
		
        // Only allow dragging if the selected cell is valid and not empty
        if (_self.selected_x >= 0 && _self.selected_x < width 
		&&  _self.selected_y >= 0 && _self.selected_y < height 
		&&  _self.grid[_self.selected_x, _self.selected_y].type != BLOCK.NONE
		&&  _self.grid[_self.selected_x, _self.selected_y].is_big == false)
		{
            _self.dragged = false; // Prepare for dragging
        } 
		else 
		{
            // Reset selection if clicking on an empty space
            _self.selected_x = -1;
            _self.selected_y = -1;
        }
    }

        // ✅ Ensure swap only happens for the initially hovered block
    if (mouse_check_button(mb_left) && !_self.dragged && _self.selected_x != -1 && _self.selected_y != -1) {
        var target_x = floor((pointer_x - board_x_offset) / gem_size);
        var target_y = _self.selected_y; // 🔹 Lock Y so swap happens on the same row

        if (target_x >= 0 && target_x < width && target_x != _self.selected_x) {
            start_swap(_self, _self.selected_x, _self.selected_y, target_x, _self.selected_y);
            _self.selected_x = target_x; 
            _self.dragged = true;
        }
    }

    // When the left mouse button is released
    if (mouse_check_button_released(mb_left)) {
        _self.selected_x = -1;
        _self.selected_y = -1;
        _self.dragged = false;
    }
}


