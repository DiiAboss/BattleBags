/// @description Enum for Enemy Attack Types
enum ENEMY_ATTACK_TYPE {
    BASIC,   // Regular shape attacks
    SPECIAL, // Triangle attack or other unique patterns
    FREEZE,  // Freezes player movement
    UNKNOWN  // Any undefined attack
}

/// @description Selects the enemy attack and stores target blocks if needed
function select_enemy_attack(_self) {
    var total_attacks = _self.total_attacks;
    var attacks_until_special = _self.attacks_until_special_attack;

    if (total_attacks % attacks_until_special == 0) {
        var atk_type = choose(ENEMY_ATTACK_TYPE.FREEZE, ENEMY_ATTACK_TYPE.FREEZE);

        if (obj_game_control.player_level > 10) {
            atk_type = choose(atk_type, atk_type, ENEMY_ATTACK_TYPE.BASIC);
        }

        if (atk_type == ENEMY_ATTACK_TYPE.SPECIAL) {
            _self.enemy_attack = "triangle_down_3x3"; 
        } else if (atk_type == ENEMY_ATTACK_TYPE.FREEZE) {
            _self.enemy_attack = "FREEZE";
            select_attack_targets(_self, "FREEZE"); // ✅ Generate target blocks
        }

    } else {
        var atk_type = choose(ENEMY_ATTACK_TYPE.FREEZE, ENEMY_ATTACK_TYPE.FREEZE);
        
        if (atk_type == ENEMY_ATTACK_TYPE.BASIC) {
            _self.enemy_attack = enemy_attack_basic(_self, obj_game_control);
        } else {
            _self.enemy_attack = "FREEZE";
            select_attack_targets(_self, "FREEZE"); // ✅ Generate target blocks
        }
    }

    ds_list_add(global.enemy_attack_queue, _self.enemy_attack);

    _self.enemy_attack_ready = true;
    _self.preview_build_timer = 0;
    _self.preview_blocks_built = 0;
}



/// @description Selects target blocks for an upcoming attack
/// @param {id} _self
/// @param {string} attack_type - The attack that will be executed (e.g., "FREEZE")
function select_attack_targets(_self, attack_type) {
    ds_list_clear(_self.target_blocks); // ✅ Reset previous targets

    var grid_width      = obj_game_control.width;
    var grid_bottom_row = obj_game_control.bottom_playable_row;
    var grid_top_row    = obj_game_control.top_playable_row;

    if (attack_type == "FREEZE") {
        var num_targets = irandom_range(1, 4); // 🔥 Random number of blocks to freeze
        var candidates = ds_list_create();

        // ✅ Collect all valid, non-frozen blocks
        for (var _y = grid_top_row; _y <= grid_bottom_row; _y++) {
            for (var _x = 0; _x < grid_width; _x++) {
                var _block = obj_game_control.grid[_x, _y];

                if (_block.type != BLOCK.NONE && !_block.frozen) { 
                    ds_list_add(candidates, [_x, _y]); // Store (x, y)
                }
            }
        }

        // ✅ If no valid targets, exit function
        if (ds_list_size(candidates) == 0) {
            ds_list_destroy(candidates);
            return;
        }

        // ✅ Pick random targets from candidates list
        for (var i = 0; i < min(num_targets, ds_list_size(candidates)); i++) {
            var target_index = irandom(ds_list_size(candidates) - 1);
            var target_position = ds_list_find_value(candidates, target_index);

            ds_list_add(_self.target_blocks, target_position);
            ds_list_delete(candidates, target_index); // Remove selected to prevent duplicates
        }

        ds_list_destroy(candidates); // ✅ Destroy after use
    }
}


/// @description Executes an attack on the stored targets
/// @param {id} _self
/// @param {string} attack_type - The attack to apply (e.g., "FREEZE")
function execute_attack_on_targets(_self, attack_type) {
    if (attack_type == "FREEZE") {
        enemy_attack_freeze(_self, obj_game_control);
    }

    // ✅ Clear the target list after execution
    ds_list_clear(_self.target_blocks);
}


/// @description Handles the attack queue system
function process_attack_queue(_self) {
    if (ds_list_size(global.enemy_attack_queue) > 0) {
        if (_self.queued_attack_timer >= _self.max_queued_attack_timer) {
            var attack_to_execute = ds_list_find_value(global.enemy_attack_queue, 0);
            ds_list_delete(global.enemy_attack_queue, 0);

            if (attack_to_execute == "FREEZE") {
               
                _self.pending_attack = "FREEZE"; // ✅ Store attack for delayed execution
                alarm[0] = max_queued_attack_timer; // ✅ Delay actual attack execution by 30 frames
            } else {
                toss_down_shape(obj_game_control, attack_to_execute, true);
            }

            _self.queued_attack_timer = 0;

            if (ds_list_size(global.enemy_attack_queue) == 0) {
                _self.attack_queue_active = false;
                _self.enemy_attack_ready = false;
            }
        } else {
            _self.queued_attack_timer += 1;
        }
    }
}


/// @description Creates an animation effect before executing an attack
function animate_attack_targets(_self, attack_type) {
    for (var i = 0; i < ds_list_size(_self.target_blocks); i++) {
        var target = ds_list_find_value(_self.target_blocks, i);
        var target_x = target[0];
        var target_y = target[1];

        if (attack_type == "FREEZE") {
            var px = (target_x * obj_game_control.gem_size) + obj_game_control.board_x_offset + 32;
            var py = (target_y * obj_game_control.gem_size) + obj_game_control.global_y_offset + 32;
			//effect_create_depth(_self.depth - 99, ef_smoke, px + irandom(64), py + irandom(64), 2, c_blue);
            //effect_create_depth(_self.depth - 99, ef_smoke, px + irandom(64), py + irandom(64), 2, c_blue);
			//effect_create_depth(_self.depth - 99, ef_smoke, px + irandom(64), py + irandom(64), 2, c_blue);
			//effect_create_depth(_self.depth - 99, ef_smoke, px + irandom(64), py + irandom(64), 2, c_blue);
			draw_sprite(spr_enemy_gem_overlay, 0, px, py);
        }
    }
}



