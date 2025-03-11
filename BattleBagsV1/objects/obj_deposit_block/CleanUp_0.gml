/// @description Clean up data structures

// Destroy the block weights map
if (ds_exists(block_weights, ds_type_map)) {
    ds_map_destroy(block_weights);
}