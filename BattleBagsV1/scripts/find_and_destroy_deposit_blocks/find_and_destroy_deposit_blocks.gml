// Script Created By DiiAboss AKA Dillon Abotossaway
/// destroy_matches(obj)
// Checks for matches & removes blocks
function destroy_matches(_block) {
    var matches = find_matches(_block);

    if (ds_list_size(matches) >= 3) {
        for (var i = 0; i < ds_list_size(matches); i++) {
            var match_block = ds_list_find_value(matches, i);
            if (instance_exists(match_block)) instance_destroy(match_block);
        }
    }

    ds_list_destroy(matches);
}

/// find_matches(obj)
    // Finds all connected deposit blocks of the same type
    function find_matches(_start_block) {
        var match_list = ds_list_create();
        
        var checked_blocks = ds_map_create(); // Prevent duplicates
        var to_check = ds_list_create();
        
        ds_list_add(to_check, _start_block); // Start with the given block
        
        while (ds_list_size(to_check) > 0) {
            var current_block = ds_list_find_value(to_check, 0);
            ds_list_delete(to_check, 0); // Remove from list
    
            if (current_block == noone) continue; // Skip if destroyed
    
            var key = string(current_block.id);
            if (ds_map_exists(checked_blocks, key)) continue; // Skip if already checked
            ds_map_add(checked_blocks, key, true);
    
            ds_list_add(match_list, current_block);
    
            // Check adjacent blocks (left, right, up, down)
            var neighbors = [
                instance_place(current_block.x - scale, current_block.y, obj_deposit_block),
                instance_place(current_block.x + scale, current_block.y, obj_deposit_block),
                instance_place(current_block.x, current_block.y - scale, obj_deposit_block),
                instance_place(current_block.x, current_block.y + scale, obj_deposit_block),
            ];
    
            for (var i = 0; i < array_length(neighbors); i++) {
                var neighbor = neighbors[i];
    
                if (neighbor != noone && 
                    neighbor.current_block_type == _start_block.current_block_type &&
                    !ds_map_exists(checked_blocks, string(neighbor.id)) &&
                    neighbor.rotation_speed == 0) {
                    
                    ds_list_add(to_check, neighbor);
                }
            }
        }
    
        ds_map_destroy(checked_blocks);
        ds_list_destroy(to_check);
        
        return match_list;
    }