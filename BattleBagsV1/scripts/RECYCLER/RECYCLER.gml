function choose_weighted_block_type(deposit_blocks, _type = DEPOSIT_BLOCK.RANDOM) {

    var weighted_list = [];
    
    var __type = _type;
    if (_type) == DEPOSIT_BLOCK.RANDOM
    {
        __type = choose(DEPOSIT_BLOCK.BLOCK, DEPOSIT_BLOCK.UPGRADE);
    }
    
    // Loop through each block in deposit_blocks
    var keys = variable_struct_get_names(deposit_blocks);
    var len = array_length(keys);
    
    // Build weighted list based on type
    for (var i = 0; i < len; i++) {
        var block = deposit_blocks[$ keys[i]];
        if (block.type == __type && block.weight > 0) {
            repeat(block.weight) {
                array_push(weighted_list, keys[i]);
            }
        }
    }

    // Safety check if no weighted items exist
    if (array_length(weighted_list) == 0) {
        show_debug_message("No available blocks for type: " + string(__type));
        return undefined;
    }

    // Choose a random block from the weighted list
    var chosen_key = weighted_list[irandom(array_length(weighted_list) - 1)];
    return deposit_blocks[$ chosen_key];
}

function create_deposit_block(recycler_object, _x, _y, deposit_block_struct)
{
    var deposit_blocks = deposit_block_struct;
    
    var max_block_chance = recycler_object.block_chance;
    var max_upgrade_chance = recycler_object.upgrade_chance;
    
    var upgrade_chance = irandom(max_block_chance);
    var block_chance   = irandom(max_upgrade_chance);
    
    var __type = block_chance >= upgrade_chance ? DEPOSIT_BLOCK.BLOCK : DEPOSIT_BLOCK.UPGRADE;
    
    // Choose a block type
    var block_type = choose_weighted_block_type(deposit_blocks, __type);
    if !(block_type) return noone;
    
    // Create deposit block
    var new_block = instance_create_depth(_x, _y, 0 - 5, obj_deposit_block, block_type);
    
    // Set the block type and physics properties
    with (new_block) {
        type = block_type.type;
        current_block_type = block_type.value;
        state = "ready";
        sprite = block_type.sprite;
        rotation_speed = random_range(-1, 5);
    }
    
    return new_block;
}