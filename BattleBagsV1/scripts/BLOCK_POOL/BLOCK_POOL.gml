// Initialize pool
function initialize_block_pool(size) {
    global.block_pool = ds_list_create();
    for (var i = 0; i < size; i++) {
        ds_list_add(global.block_pool, create_block());
    }
}

// Get block from pool
function get_block_from_pool() {
    if (ds_list_size(global.block_pool) > 0) {
        var block = global.block_pool[| 0];
        ds_list_delete(global.block_pool, 0);
        return block;
    }
    return create_block(); // Create new if pool is empty
}

// Return block to pool
function return_block_to_pool(block) {
    reset_block(block);
    ds_list_add(global.block_pool, block);
}
