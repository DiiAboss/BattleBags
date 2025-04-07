// Script Created By DiiAboss AKA Dillon Abotossaway
/// destroy_matches(obj)
// Checks for matches & removes blocks, returning detailed information
function destroy_deposit_matches(_block) {
    var result = {
        matched_types: {},      // Tracks count and details by block type
        total_destroyed: 0,     // Total blocks destroyed
        total_value: 0,         // Sum of all block values
        special_blocks: []      // Any special blocks that were destroyed
    };
    
    var matches = find_matches(_block);
    if (array_length(matches) >= 3) {
        for (var i = 0; i < array_length(matches); i++) {
            var match_block = matches[i];
            if (instance_exists(match_block)) {
                var block_type_val = match_block.current_block_type;
                var block_type_key = string(block_type_val);
                
                // Track by type
                if (!variable_struct_exists(result.matched_types, block_type_key)) {
                    result.matched_types[$ block_type_key] = {
                        count: 1,
                        value: match_block.value,
                        level: match_block.level,
                        total_value: match_block.value,
                        type_enum: block_type_val
                    };
                } else {
                    result.matched_types[$ block_type_key].count++;
                    result.matched_types[$ block_type_key].total_value += match_block.value;
                }
                
                // Track special blocks
                if (variable_struct_exists(match_block.special_stats, "destroy_blocks") && 
                    match_block.special_stats.destroy_blocks) {
                    array_push(result.special_blocks, {
                        type: block_type_val,
                        level: match_block.level,
                        value: match_block.value
                    });
                }
                
                // Update totals
                result.total_destroyed++;
                result.total_value += match_block.value;
                
                // Destroy the block
                instance_destroy(match_block);
            }
        }
    }
    
    return result;
}

/// find_matches(obj)
// Finds all connected deposit blocks of the same type
function find_matches(_start_block) {
    // Safety check - if the block doesn't exist or has no type, return empty array
    if (!instance_exists(_start_block) || _start_block.current_block_type == BLOCK.NONE) {
        return [];
    }
    
    var match_list = [];
    var checked_blocks = {}; // Prevent duplicates using a struct
    var to_check = [_start_block]; // Start with the given block
    
    while (array_length(to_check) > 0) {
        var current_block = to_check[0];
        array_delete(to_check, 0, 1); // Remove first element
        
        if (!instance_exists(current_block)) continue; // Skip if destroyed
        
        var key = string(current_block.id);
        if (variable_struct_exists(checked_blocks, key)) continue; // Skip if already checked
        checked_blocks[$ key] = true;
        
        array_push(match_list, current_block);
        
        // Check adjacent blocks (left, right, up, down)
        var neighbors = array_create(4, noone);
        neighbors[0] = instance_place(current_block.x - current_block.scale, current_block.y, obj_deposit_block);
        neighbors[1] = instance_place(current_block.x + current_block.scale, current_block.y, obj_deposit_block);
        neighbors[2] = instance_place(current_block.x, current_block.y - current_block.scale, obj_deposit_block);
        neighbors[3] = instance_place(current_block.x, current_block.y + current_block.scale, obj_deposit_block);
        
        for (var i = 0; i < array_length(neighbors); i++) {
            var neighbor = neighbors[i];
            
            if (instance_exists(neighbor) && 
                neighbor.current_block_type == _start_block.current_block_type &&
                !variable_struct_exists(checked_blocks, string(neighbor.id)) &&
                neighbor.rotation_speed == 0 &&
                neighbor.falling == false) {
                
                array_push(to_check, neighbor);
            }
        }
    }
    
    return match_list;
}