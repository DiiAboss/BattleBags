

function block_dragged(_self, action_key_pressed = mouse_check_button_pressed(mb_left), action_key_hold = mouse_check_button(mb_left), release_key = mouse_check_button_released(mb_left), pointer_x = mouse_x, pointer_y = mouse_y) {
	
	//var input = _self.input;
	
	var width = _self.width;
	var height = _self.height;
	var board_x_offset = _self.board_x_offset;
	var gem_size = _self.gem_size;
	var global_y_offset = _self.global_y_offset;
	
	    // 🔹 Convert mouse coordinates to grid indices
    var hover_x = _self.hover_x;
    var hover_y = _self.hover_y;
	
	// ✅ Store hovered block for **drawing**
	if (hover_x >= 0 && hover_x < width && hover_y >= 0 && hover_y < height) {
	    _self.hovered_block = [hover_x, hover_y]; // Store for later use
	} else {
	    _self.hovered_block = [-1, -1]; // Reset if out of bounds
	}
	
    // When the left mouse button is pressed, record the starting cell
    if (action_key_pressed) {
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
			if _self.grid[hover_x, hover_y].freeze_timer > 0
			{
				_self.grid[hover_x, hover_y].freeze_timer -= 20;
				effect_create_depth(_self.depth - 99, ef_smoke, (hover_x * gem_size) + board_x_offset + 32, (hover_y * gem_size) + global_y_offset + 32, 1, c_blue);
			}
			
        } 
		else 
		{
            // Reset selection if clicking on an empty space
            _self.selected_x = -1;
            _self.selected_y = -1;
        }
    }

        // ✅ Ensure swap only happens for the initially hovered block
    if (action_key_hold && !_self.dragged && _self.selected_x != -1 && _self.selected_y != -1) {
        var target_x = floor((pointer_x - board_x_offset) / gem_size);
        var target_y = _self.selected_y; // 🔹 Lock Y so swap happens on the same row

        if (target_x >= 0 && target_x < width && target_x != _self.selected_x) {
            start_swap(_self, _self.selected_x, _self.selected_y, target_x, _self.selected_y);
            _self.selected_x = target_x; 
            _self.dragged = true;
        }
    }

    // When the left mouse button is released
    if (release_key) {
        _self.selected_x = -1;
        _self.selected_y = -1;
        _self.dragged = false;
    }
}


function mouse_legacy_swap(_self, action_key_pressed) {
    var width          = _self.width;
    var height         = _self.height;
    var board_x_offset = _self.board_x_offset;
    var gem_size       = _self.gem_size;
    var global_y_offset = _self.global_y_offset;

    // 🔹 Convert mouse coordinates to grid indices
    var hover_x = _self.hover_x;
    var hover_y = _self.hover_y;

    // ✅ Store hovered block for UI feedback
    if (hover_x >= 0 && hover_x < width && hover_y >= 0 && hover_y < height) {
        _self.hovered_block = [hover_x, hover_y];
    } else {
        _self.hovered_block = [-1, -1]; // Reset if out of bounds
    }

    // ✅ When the left mouse button is pressed, attempt to swap
    if (action_key_pressed) {
        if (hover_x >= 0 && hover_x < width - 1 // Ensure it's not on the right edge
            && hover_y >= 0 && hover_y < height
            //&& _self.grid[hover_x, hover_y].type != BLOCK.NONE // Must be a valid block
            && _self.grid[hover_x, hover_y].is_big == false) { // Cannot swap big blocks

            var target_x = hover_x + 1;
            var target_y = hover_y;

            // ✅ Check if the right-side block is valid for swapping
            //if (_self.grid[target_x, target_y].type != BLOCK.NONE 
                if _self.grid[target_x, target_y].is_big == false {
                
                start_swap(_self, hover_x, hover_y, target_x, target_y);
            }
        }
    }
}
