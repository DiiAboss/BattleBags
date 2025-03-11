/// @description Free data structures

// Destroy the block list
if (ds_exists(conveyor_blocks, ds_type_list)) {
    ds_list_destroy(conveyor_blocks);
}

// Destroy the sprite cache
if (ds_exists(block_sprites, ds_type_map)) {
    ds_map_destroy(block_sprites);
}