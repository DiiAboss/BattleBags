function freeze_block(_self, _x, _y, freeze_duration = 10) {
    var freeze_x = _x;
    var freeze_y = _y;

    var gem = _self.grid[freeze_x, freeze_y];

    if (gem.type != BLOCK.NONE && !gem.frozen && !gem.is_big) { // Ensure it's a valid and unfrozen block
        gem.frozen = true;
        gem.freeze_timer = 60 * freeze_duration; // Freeze duration in seconds
    }
}


/// @description Executes the freeze attack using stored target blocks
function enemy_attack_freeze(_self, game_control_object) {
    for (var i = 0; i < ds_list_size(_self.target_blocks); i++) {
        var target = ds_list_find_value(_self.target_blocks, i);
        var target_x = target[0];
        var target_y = target[1];

        freeze_block(game_control_object, target_x, target_y, 5 + _self.attack_power); 
    }

    // ✅ Clear the target list after execution
    ds_list_clear(_self.target_blocks);
}

function slime_block(_self, _x, _y, slime_hp = 10) {
    var slime_x = _x;
    var slime_y = _y;

    var gem = _self.grid[slime_x, slime_y];

    if (gem.type != BLOCK.NONE && !gem.frozen && !gem.is_big) { // Ensure it's a valid and unfrozen block
        gem.slime_hp = slime_hp;
		gem.max_fall_delay = 20; // ✅ Make it fall slower
        gem.swap_speed = 0.075;   // ✅ Make it swap slower
    }
}


/// @description Executes the freeze attack using stored target blocks
function enemy_attack_slime(_self, game_control_object) {
    for (var i = 0; i < ds_list_size(_self.target_blocks); i++) {
        var target = ds_list_find_value(_self.target_blocks, i);
        var target_x = target[0];
        var target_y = target[1];

        slime_block(game_control_object, target_x, target_y, 5 + _self.attack_power); 
    }

    // ✅ Clear the target list after execution
    ds_list_clear(_self.target_blocks);
}