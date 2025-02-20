function block_dragged_mp(mp_control, player) {
        var input = player.input;
        var width = mp_control.width;
        var height = mp_control.height;
        var board_x_offset = player.board_x_offset;
        var gem_size = mp_control.gem_size;
        var global_y_offset = player.global_y_offset;
        
        // 🔹 Convert pointer position to player's grid coordinates
        var hover_x = floor((player.pointer_x - board_x_offset) / gem_size);
        var hover_y = floor((player.pointer_y - global_y_offset) / gem_size);
        
        // ✅ Ensure hover is within player’s grid
        if (hover_x >= 0 && hover_x < width && hover_y >= 0 && hover_y < height) {
            player.hovered_block = [hover_x, hover_y];
        } else {
            player.hovered_block = [-1, -1]; // Reset if out of bounds
        }
    
        // ✅ Select block when action key is pressed (ONLY within player's grid)
        if (input.ActionPress) {
            player.selected_x = hover_x;
            player.selected_y = hover_y;
    
            // ✅ Ensure valid block selection
            if (player.selected_x >= 0 && player.selected_x < width &&
                player.selected_y >= 0 && player.selected_y < height &&
                player.grid[player.selected_x, player.selected_y].type != BLOCK.NONE &&
                !player.grid[player.selected_x, player.selected_y].is_big) {
    
                player.dragged = false; // Prepare for dragging
    
                // ✅ Reduce freeze timer if applicable
                if (player.grid[hover_x, hover_y].freeze_timer > 0) {
                    player.grid[hover_x, hover_y].freeze_timer -= 20;
                    effect_create_depth(mp_control.depth - 99, ef_smoke, 
                                        (hover_x * gem_size) + board_x_offset + 32, 
                                        (hover_y * gem_size) + global_y_offset + 32, 
                                        1, c_blue);
                }
            } else {
                // Reset selection if clicking on an invalid block
                player.selected_x = -1;
                player.selected_y = -1;
            }
        }
    
        // ✅ Swap logic when dragging
        if (input.ActionKey && !player.dragged && player.selected_x != -1) {
            var target_x = floor((player.pointer_x - board_x_offset) / gem_size);
            var target_y = player.selected_y; // Lock Y so swap happens in the same row
    
            // ✅ Ensure swap stays within player's board
            if (target_x >= 0 && target_x < width && target_x != player.selected_x) {
                start_swap_mp(mp_control, player, player.selected_x, player.selected_y, target_x, player.selected_y);
                player.selected_x = target_x;
                player.dragged = true;
            }
        }
    
        // ✅ Reset selection when the action key is released
        if (input.ActionRelease) {
            player.selected_x = -1;
            player.selected_y = -1;
            player.dragged = false;
        }
    }
    
    function block_legacy_swap(mp_control, player) {
        var input = player.input;
        var width = mp_control.width;
        var height = mp_control.height;
        var board_x_offset = player.board_x_offset;
        var gem_size = mp_control.gem_size;
        var global_y_offset = player.global_y_offset;
    
        // 🔹 Convert mouse position to player’s board coordinates
        var hover_x = player.hovered_block[0];
        var hover_y = player.hovered_block[1];

    
        // ✅ When the action key is pressed, attempt to swap
        if (input.ActionPress) {
            if (hover_x >= 0 && hover_x < width - 1 // Ensure it's not on the right edge
                && hover_y >= 0 && hover_y < height
                && !player.grid[hover_x, hover_y].is_big) { // Cannot swap big blocks
    
                var target_x = hover_x + 1;
                var target_y = hover_y;
    
                // ✅ Check if the right-side block is valid for swapping
                if (!player.grid[target_x, target_y].is_big) {
                    start_swap_mp(self, player, hover_x, hover_y, target_x, target_y);
                }
            }
        }
    }