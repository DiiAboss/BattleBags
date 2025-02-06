function generate_map() {
    var num_rows = 6;  // Total rows (start at 9, boss at 0)
    var max_cols = 6;   // Widest part of the map
    var row_spacing = room_height / num_rows; // Even row spacing
    var col_spacing = room_width / max_cols;  // Even column spacing

    global.path_nodes = ds_list_create();
    var node_grid = array_create(num_rows, []);

    // ✅ Create the start node (always in the middle bottom)
    var start_x = room_width / 2;
    var start_y = room_height - row_spacing / 2;
    var start_node = instance_create_depth(start_x, start_y, 0, obj_map_point_parent);
    start_node.row = num_rows - 1;
    start_node.col = floor(max_cols / 2);
    ds_list_add(global.path_nodes, start_node);
    node_grid[num_rows - 1] = [start_node];

    // ✅ Generate structured rows from bottom to top
    for (var r = num_rows - 2; r > 0; r--) {
        var width_factor = min(r + 1, max_cols); // Expand in middle, contract at top
        var num_nodes = irandom_range(2, width_factor); // Random nodes in range
        node_grid[r] = [];

        for (var i = 0; i < num_nodes; i++) {
            // 🔹 Set x position with slight randomness within a column space
            var node_x = (i + 0.5) * (room_width / width_factor) + irandom_range(-20, 20);
            var node_y = r * row_spacing + irandom_range(-10, 10);

            var new_node = instance_create_depth(node_x, node_y, 0, obj_map_point_parent);
            new_node.row = r;
            new_node.col = i;
            ds_list_add(global.path_nodes, new_node);
            array_push(node_grid[r], new_node);
        }
    }

    // ✅ Create the boss node (always at the top center)
    var boss_x = room_width / 2;
    var boss_y = row_spacing / 2;
    var boss_node = instance_create_depth(boss_x, boss_y, 0, obj_map_point_parent);
    boss_node.row = 0;
    ds_list_add(global.path_nodes, boss_node);
    node_grid[0] = [boss_node];

    // ✅ Connect nodes properly
    connect_nodes(node_grid);
}


function connect_nodes(_node_grid) {
    var num_rows = array_length(_node_grid);

    // ✅ Step 1: Ensure the start node connects to the row above
    var start_row = _node_grid[num_rows - 1];
    var first_row = _node_grid[num_rows - 2];

    if (start_row != undefined && first_row != undefined && array_length(first_row) > 0) {
        var start_node = start_row[0]; // 🔹 Start node is always the first node
        var parent_index = irandom(array_length(first_row) - 1);
        start_node.parent = first_row[parent_index]; // 🔹 Connect to a random node above
    }

    // ✅ Step 2: Loop through and connect the rest of the rows
    for (var r = num_rows - 2; r > 0; r--) { // ✅ Ensures `r - 1` is always valid
        var current_row = _node_grid[r];
        var above_row = _node_grid[r - 1];

        // ✅ Ensure the row exists before processing
        if (current_row == undefined || above_row == undefined || array_length(above_row) == 0) continue;

        for (var i = 0; i < array_length(current_row); i++) {
            var node = current_row[i];

            // 🔹 Connect each node to **1-2 parents** from the row above
            var parent_count = irandom_range(1, min(2, array_length(above_row))); // Prevents over-indexing

            for (var p = 0; p < parent_count; p++) {
                var parent_index = irandom(array_length(above_row) - 1); // ✅ Prevents out-of-range error
                var parent_node = above_row[parent_index];

                if (parent_node != undefined) {
                    node.parent = parent_node;
                }
            }
        }
    }
}







function generate_branches(node_grid, start_node, boss_node, max_branches) {
    var num_rows = array_length(node_grid);

    for (var r = num_rows - 1; r >= 0; r--) {
        var nodes = node_grid[r];

        for (var i = 0; i < array_length(nodes); i++) {
            var node = nodes[i];

            // ✅ If it's the bottom row, connect to the start node
            if (r == num_rows - 1) {
                node.parent = start_node;
            }
            // ✅ If it's the top row, connect to the boss
            else if (r == 0) {
                node.parent = boss_node;
            }
            // ✅ Otherwise, randomly connect to nodes above
            else {
                var next_row_nodes = node_grid[r - 1];
                if (array_length(next_row_nodes) > 0) {
                    var num_parents = irandom_range(1, max_branches);

                    for (var j = 0; j < num_parents; j++) {
                        var parent_index = irandom(array_length(next_row_nodes) - 1);
                        var parent_node = next_row_nodes[parent_index];

                        if (parent_node != noone) {
                            node.parent = parent_node;
                        }
                    }
                }
            }
        }
    }
}


function connect_final_nodes_to_boss(_boss_node) {
    for (var i = 0; i < ds_list_size(global.path_nodes); i++) {
        var node = ds_list_find_value(global.path_nodes, i);

        // If the node is in the top row and not the boss node, connect it to the boss
        if (node.row == 0 && node._id != _boss_node._id) {
            node.parent = _boss_node;
        }
    }
}

function array_contains(_array, _value) {
    for (var i = 0; i < array_length(_array); i++) {
        if (_array[i][0] == _value[0] && _array[i][1] == _value[1]) return true;
    }
    return false;
}

function scr_array_delete(_array, _index) {
    if (_index < 0 || _index >= array_length(_array)) return _array;
    var new_array = [];
    for (var i = 0; i < array_length(_array); i++) {
        if (i != _index) array_push(new_array, _array[i]);
    }
    return new_array;
}

function draw_map_connections(_nodes, _dash_step) {
    for (var i = 0; i < ds_list_size(_nodes); i++) {
        var node = ds_list_find_value(_nodes, i);

        if (node != noone && variable_instance_exists(node, "parent") && node.parent != noone) {
            var x1 = node.x;
            var y1 = node.y;
            var x2 = node.parent.x;
            var y2 = node.parent.y;

            draw_set_color(c_white);
            draw_dashed_line(x1, y1, x2, y2, _dash_step);
        }
    }
}

// 🔹 Dashed Line Drawer
function draw_dashed_line(x1, y1, x2, y2, _step) {
    var dist = point_distance(x1, y1, x2, y2);
    var step_count = floor(dist / _step);
    
    for (var i = 0; i < step_count; i += 2) {
        var t1 = i / step_count;
        var t2 = (i + 1) / step_count;
        
        var px1 = lerp(x1, x2, t1);
        var py1 = lerp(y1, y2, t1);
        var px2 = lerp(x1, x2, t2);
        var py2 = lerp(y1, y2, t2);
        
        draw_line(px1, py1, px2, py2);
    }
}


