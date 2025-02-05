function mouse_dragged(_self, pointer_x = mouse_x, pointer_y = mouse_y) {
	
	var width = _self.width;
	var height = _self.height;
	var board_x_offset = _self.board_x_offset;
	var gem_size = _self.gem_size;
	var global_y_offset = _self.global_y_offset;
	
    // When the left mouse button is pressed, record the starting cell
    if (mouse_check_button_pressed(mb_left)) {
        // Convert mouse coordinates to grid indices
        _self.selected_x = floor((pointer_x - board_x_offset) / gem_size);
        _self.selected_y = floor((pointer_y - global_y_offset) / gem_size);

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

    // While the left mouse button is held down
    if (mouse_check_button(mb_left)) {
        if (!_self.dragged && _self.selected_x != -1 && _self.selected_y != -1) 
		{
		    var current_x = floor((pointer_x - board_x_offset) / gem_size);
		    var current_y = floor((pointer_y - global_y_offset) / gem_size);

		   if (current_x >= 0 && current_x < width 
		   &&  current_y == _self.selected_y // Horizontal swaps only
		   &&  current_x != _self.selected_x) 
		   {
			    start_swap(_self, _self.selected_x, _self.selected_y, current_x, _self.selected_y);
			    _self.selected_x = current_x;
			    _self.dragged = true;
			}
		}
    }

    // When the left mouse button is released
    if (mouse_check_button_released(mb_left)) {
        _self.selected_x = -1;
        _self.selected_y = -1;
        _self.dragged = false;
    }
}