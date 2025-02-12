// Script Created By DiiAboss AKA Dillon Abotossaway
///@function shift_up
///
///@description Moves the entire board up by one row, including buffer spaces.
///
///@param {id} _self - The game object that contains the grid.

function shift_up(_self) {
    var width = _self.width;
    var height = _self.height;

    // 1️⃣ Shift from bottom to top (including buffer zones)
    for (var j = 0; j < height - 1; j++) { // ✅ Process all rows, including buffers
        for (var i = 0; i < width; i++) {
            var gem = _self.grid[i, j];

			// ✅ Process **Big Blocks** shifting upwards
			if (gem.is_big) {
			    var parent_x = gem.big_parent[0];
			    var parent_y = gem.big_parent[1];
			    var parent_block = _self.grid[parent_x, parent_y];
			    var big_block_width = parent_block.mega_width;
			    var big_block_height = parent_block.mega_height;

			    // ✅ Only process once for the **parent block**
			    if (i == parent_x && j == parent_y) {
			        var new_y = parent_y - 1; // 🔹 Move up one row

			            // ✅ Move the entire Mega Block **up one row**
			            for (var bx = 0; bx < big_block_width; bx++) {
			                for (var by = 0; by < big_block_height; by++) {
			                    var old_x = parent_x + bx;
			                    var old_y = parent_y + by;
			                    var new_x = old_x;
			                    var new_y_pos = old_y - 1; // 🔹 Shift Up

			                    _self.grid[new_x, new_y_pos] = _self.grid[old_x, old_y]; // Move
			                    _self.grid[old_x, old_y] = create_block(BLOCK.NONE); // Clear Old
			                    _self.grid[new_x, new_y_pos].big_parent = [parent_x, new_y]; // ✅ Update parent reference
			                }
			            }

			            // ✅ Ensure Mega Block remains properly referenced
			            _self.grid[parent_x, new_y].mega_width = big_block_width;
			            _self.grid[parent_x, new_y].mega_height = big_block_height;
			    }
			} 
			else
			{
				// ✅ Normal gem movement
			    _self.grid[i, j] = _self.grid[i, j + 1];
			}


        }
    }

    // 2️⃣ Shift all popping gems in `global.pop_list`
    for (var k = 0; k < ds_list_size(global.pop_list); k++) {
        var pop_data = ds_list_find_value(global.pop_list, k);
        
        // ✅ Move each popping gem up **one row**
        pop_data.y -= 1;
        pop_data.y_offset_global = global_y_offset;
        
        ds_list_replace(global.pop_list, k, pop_data);
    }

    // 3️⃣ Spawn a new random row at the **very bottom of the grid**
    for (var i = 0; i < width; i++) {
        // ✅ Ensure **only spawn new blocks in the last row**
        _self.grid[i, height - 1] = create_block(BLOCK.RANDOM);
    }

    // 4️⃣ Reset darken alpha so the new row fades in again
    _self.darken_alpha = 0;
	number_of_rows_spawned ++;
}


            //// ✅ If it's part of a big block, check if it needs bottom row
            //if (gem.is_big) {
            //    var parent_x = gem.big_parent[0];
            //    var parent_y = gem.big_parent[1];

            //    // ✅ Only process the parent block
            //    if (i == parent_x && j + 1 == parent_y) {
            //        var new_y = parent_y - 1;

            //        // ✅ Move entire 2x2 block up
            //        _self.grid[parent_x,     new_y]    = _self.grid[parent_x,     parent_y];
            //        _self.grid[parent_x + 1, new_y]    = _self.grid[parent_x + 1, parent_y];
            //        _self.grid[parent_x,     parent_y] = _self.grid[parent_x,     parent_y + 1];
            //        _self.grid[parent_x + 1, parent_y] = _self.grid[parent_x + 1, parent_y + 1];

            //        // ✅ Update big_parent
            //        _self.grid[parent_x,     new_y].big_parent     = [parent_x, new_y];
            //        _self.grid[parent_x + 1, new_y].big_parent     = [parent_x, new_y];
            //        _self.grid[parent_x,     new_y + 1].big_parent = [parent_x, new_y];
            //        _self.grid[parent_x + 1, new_y + 1].big_parent = [parent_x, new_y];

            //        // ✅ Mark as "big"
            //        _self.grid[parent_x,     new_y].is_big     = true;
            //        _self.grid[parent_x + 1, new_y].is_big     = true;
            //        _self.grid[parent_x,     new_y + 1].is_big = true;
            //        _self.grid[parent_x + 1, new_y + 1].is_big = true;