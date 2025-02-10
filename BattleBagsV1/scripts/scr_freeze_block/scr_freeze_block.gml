function freeze_block(_self, _x, _y, freeze_duration = 10) {
    var freeze_x = _x;
    var freeze_y = _y;

    var gem = _self.grid[freeze_x, freeze_y];

    if (gem.type != BLOCK.NONE && !gem.frozen) { // Ensure it's a valid and unfrozen block
        gem.frozen = true;
        gem.freeze_timer = 60 * freeze_duration; // Freeze duration in seconds
    }
}


function enemy_attack_freeze(_self, game_control_object) {
    var width = game_control_object.width;
    var height = game_control_object.bottom_playable_row;

    // **How many blocks to freeze?** (Depends on attack level)
    var num_blocks_to_freeze = _self.attack; // **Freeze count scales with attack power**
    
    // ✅ List of available blocks to freeze
    var candidates = ds_list_create();
    
    for (var i = 0; i < width; i++) {
        for (var j = 0; j < height; j++) {
            if (game_control_object.grid[i, j].type != BLOCK.NONE && !game_control_object.grid[i, j].frozen) {
                ds_list_add(candidates, {x: i, y: j});
            }
        }
    }

    // ✅ Shuffle and select random blocks to freeze
    for (var k = 0; k < min(num_blocks_to_freeze, ds_list_size(candidates)); k++) {
        var index = irandom(ds_list_size(candidates) - 1);
        var block = ds_list_find_value(candidates, index);
        
        freeze_block(game_control_object, block.x, block.y, 5 + _self.attack); // **Longer freezes for stronger attacks**
        
        ds_list_delete(candidates, index);
    }

    ds_list_destroy(candidates);
}
