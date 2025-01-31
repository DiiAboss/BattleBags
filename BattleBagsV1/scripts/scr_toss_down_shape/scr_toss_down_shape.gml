function toss_down_shape(_self, shape_name) {
    var width = _self.width;
    var height = _self.height;
    var gem_size = _self.gem_size;

    // ✅ Use ds_map_find_value() to get the shape template
    var shape = ds_map_find_value(global.shape_templates, shape_name);

    if (shape == undefined) return; // ✅ Prevent errors if shape not found

    var shape_width = array_length(shape[0]);
    var shape_height = array_length(shape);

    // ✅ Choose a **random starting X position** (ensure it fits)
    var start_x = irandom_range(0, width - shape_width);

    // ✅ Place shape into the grid at row 0
    for (var j = 0; j < shape_height; j++) {
        for (var i = 0; i < shape_width; i++) {
            if (shape[j][i] == 1) { // ✅ Only place gems where `1` exists
                var gem_x = start_x + i;
                var gem_y = j;

                if (gem_x >= 0 && gem_x < width && gem_y >= 0 && gem_y < height) {
                    var new_gem = create_gem(irandom_range(0, _self.numberOfGemTypes - 1));
                    _self.grid[gem_x, gem_y] = new_gem;
                    //_self.gem_y_offsets[gem_x, gem_y] = -gem_size * 2; // Start above
                    _self.grid[gem_x, gem_y].falling = true;
                    _self.grid[gem_x, gem_y].fall_delay = 0; // **No delay before falling**
                }
            }
        }
    }

    // ✅ Force a secondary drop pass **to process falling blocks**
    for (var i = 0; i < 3; i++) { // Run multiple passes to prevent a hang
        drop_blocks(_self);
    }
}

//function toss_down_shape(_self, shape_name, use_black_blocks = false) {
//    var width = _self.width;
//    var height = _self.height;
//    var gem_size = _self.gem_size;

//    // ✅ Use ds_map_find_value() to get the shape template
//    var shape = ds_map_find_value(global.shape_templates, shape_name);
//    if (shape == undefined) return; // ✅ Prevent errors if shape not found

//    var shape_width = array_length(shape[0]);
//    var shape_height = array_length(shape);

//    // ✅ Choose a **random starting X position** (ensure it fits)
//    var start_x = irandom_range(0, width - shape_width);

//    // ✅ Create a queue for row spawning
//    _self.shape_spawn_queue = ds_list_create();
//    _self.shape_spawn_timer = 30; // Adjust delay between rows

//    // ✅ Store each row in the queue
//    for (var j = 0; j < shape_height; j++) {
//        var row_data = []; // ✅ Use a **dynamic array**, NOT a ds_list
//        var row_size = 0; // ✅ Track array size manually

//        for (var i = 0; i < shape_width; i++) {
//            if (shape[j][i] == 1) { // ✅ Only place gems where `1` exists
//                var gem_x = start_x + i;
//                var gem_y = j;

//                if (gem_x >= 0 && gem_x < width && gem_y >= 0 && gem_y < height) {
//                    array_resize(row_data, row_size + 1);
//                    row_data[row_size] = [gem_x, gem_y, use_black_blocks]; // Store position
//                    row_size++;
//                }
//            }
//        }

//        // ✅ Add this row to the spawn queue **as an array**
//        ds_list_add(_self.shape_spawn_queue, row_data);
//    }
//}

//function spawn_next_shape_row(_self) {
//    if (!ds_list_size(_self.shape_spawn_queue)) return; // ✅ No more rows to spawn

//    _self.shape_spawn_timer--; // ⏳ Decrease timer
//    if (_self.shape_spawn_timer > 0) return; // ❌ Wait until timer reaches 0

//    // ✅ Reset timer for next row
//    _self.shape_spawn_timer = 10;

//    // ✅ Get the next row to spawn
//    var row_data = ds_list_find_value(_self.shape_spawn_queue, 0);
//    ds_list_delete(_self.shape_spawn_queue, 0); // ✅ Remove row from queue

//    // ✅ Ensure `row_data` is an array before processing
//    if (!is_array(row_data)) return; 

//    var row_size = array_length(row_data);

//    // ✅ Spawn all gems in this row
//    for (var k = 0; k < row_size; k++) {
//        var gem_x = row_data[k][0];
//        var gem_y = row_data[k][1];
//        var use_black_block = row_data[k][2];

//        // ✅ Create the correct gem type
//        var new_gem = create_gem(use_black_block ? BLOCK.BLACK : irandom_range(0, _self.numberOfGemTypes - 1));
        
//        _self.grid[gem_x, gem_y] = new_gem;
//       // _self.gem_y_offsets[gem_x, gem_y] = -gem_size * 2; // Start above
//        new_gem.falling = true;
//        new_gem.fall_delay = 0; // No delay before falling
//    }

//    drop_blocks(_self); // ✅ Drop after each row spawns
//}