function start_swap_mp(mp_control, player, ax, ay, bx, by) {
            if (player.swap_in_progress) return; // Prevent stacking swaps
                
            var top_row    = mp_control.top_playable_row;
            var bottom_row = mp_control.bottom_playable_row;
        
            // ✅ Ensure swap is within playable area
            if (ay < top_row || ay > bottom_row ||
                by < top_row || by > bottom_row) return;
        
            var gemA = player.grid[ax, ay];
            var gemB = player.grid[bx, by];
        
            // ✅ Prevent swapping `big` blocks if they belong to different groups
            if (gemA.is_big || gemB.is_big) {
                if (gemA.group_id != gemB.group_id) return;
                var parentA = gemA.big_parent;
                var parentB = gemB.big_parent;
        
                if (parentA[0] != parentB[0] || parentA[1] != parentB[1]) return; // Ensure swapping whole block
            }
        
            // ✅ Execute the swap normally if no shifting is happening
            execute_swap_mp(mp_control, player, ax, ay, bx, by);
        }
        

        ///@function execute_swap
        ///
        ///@description Executes a swap between two gems, handling special cases like shifting and frozen blocks.
        ///
        ///@param {struct} mp_control - The game object managing the board.
        ///@param {struct} player - The game object managing the board.
        ///@param {real} ax - The x-coordinate of the first gem.
        ///@param {real} ay - The y-coordinate of the first gem.
        ///@param {real} bx - The x-coordinate of the second gem.
        ///@param {real} by - The y-coordinate of the second gem.
        ///
        function execute_swap_mp(mp_control, player, ax, ay, bx, by) {
            var width  = mp_control.width;
            var height = mp_control.height;
        
            // ✅ Validate swap positions (ensures within grid bounds)
            if (
                ax < 0 || ax >= width || ay < 0 || ay >= height ||
                bx < 0 || bx >= width || by < 0 || by >= height
            ) return;
            
            if (player.grid[ax, ay].slime_hp > 0)
            {
                player.grid[ax, ay].slime_hp -= 1;
            } else
            
                if (player.grid[bx, by].slime_hp > 0)
            {
                player.grid[bx, by].slime_hp -= 1;
            } else
            
            {
                // ✅ **If slime HP runs out, return to normal**
                if (player.grid[ax, ay].slime_hp <= 0) {
                    player.grid[ax, ay].max_fall_delay = 5;  // ✅ Normal falling speed
                    player.grid[ax, ay].swap_speed = 0.15;    // ✅ Normal swap speed
                }
                
                // ✅ **If slime HP runs out, return to normal**
                if (player.grid[bx, by].slime_hp <= 0) {
                    player.grid[bx, by].max_fall_delay = 5;  // ✅ Normal falling speed
                    player.grid[bx, by].swap_speed = 0.15;    // ✅ Normal swap speed
                }
            }
            
        
            // ✅ Prevent swapping if one of the gems is being destroyed
            if (is_being_destroyed_mp(player, ax, ay) || is_being_destroyed_mp(player, bx, by)) return;
        
            // ✅ Prevent swapping frozen blocks
            if (player.grid[ax, ay].frozen || player.grid[bx, by].frozen) return;
        
            // ✅ Prevent swapping MEGA blocks
            if (player.grid[ax, ay].type == BLOCK.MEGA || player.grid[bx, by].type == BLOCK.MEGA) return;
            
            var _swap_speed = min(player.grid[ax, ay].swap_speed, player.grid[bx, by].swap_speed);
        
            // 🔹 Handle row shifting logic
            if (player.global_y_offset == 0) {
                player.swap_info.from_x = ax;
                player.swap_info.from_y = ay - 1;  // ✅ Adjusting swap to account for shifting
                player.swap_info.to_x   = bx;
                player.swap_info.to_y   = by - 1;
                player.swap_info.progress = 0;
                player.swap_info.speed = _swap_speed;
            }
            else
            {
                player.swap_in_progress = true;
                player.swap_info.from_x = ax;
                player.swap_info.from_y = ay;
                player.swap_info.to_x   = bx;
                player.swap_info.to_y   = by;
                player.swap_info.progress = 0;
                player.swap_info.speed = _swap_speed;
            }
        }
        
        
        
        
        
        function process_swap_mp(player, gem_size = 48)
        {
            if !(player.swap_queue) return;
            if (player.swap_queue.active) {
                var swap_queue = player.swap_queue;
                
                // ✅ Make sure we only shift the row if a swap was NOT already shifted
                if (player.global_y_offset == 0) {
                    player.swap_queue.ay -= 1;
                    player.swap_queue.by -= 1;
                }
            
                // ✅ Execute the swap AFTER adjusting its position
                execute_swap_mp(self, player, swap_queue.ax, swap_queue.ay, swap_queue.bx, swap_queue.by);
                
                player.swap_queue.active = false; // Clear the swap queue
            }
            
            
            if (player.swap_in_progress) {
                
                player.swap_info.progress += player.swap_info.speed;
        
                // 🛑 Check if the swap is happening **mid-shift** (before progress reaches 1)
                if (player.swap_info.progress < 1 && player.global_y_offset == 0) {
                    // 🔹 Move swap targets UP by one row since the board just shifted
                    player.swap_info.from_y -= 1;
                    player.swap_info.to_y -= 1;
                }
        
                if (player.swap_info.progress >= 1) {
                    player.swap_info.progress = 1;
        
                    // ✅ Ensure the swap happens at the correct row based on whether we just shifted
                    if (player.global_y_offset != 0) {
                        var temp = player.grid[player.swap_info.from_x, player.swap_info.from_y];
                        player.grid[player.swap_info.from_x, player.swap_info.from_y] = player.grid[player.swap_info.to_x, player.swap_info.to_y];
                        player.grid[player.swap_info.to_x, player.swap_info.to_y] = temp;
                    } else {
                        // 🔹 If the board just moved up, apply the swap **one row higher**
                        var temp = player.grid[player.swap_info.from_x, player.swap_info.from_y - 1];
                        player.grid[player.swap_info.from_x, player.swap_info.from_y - 1] = player.grid[player.swap_info.to_x, player.swap_info.to_y - 1];
                        player.grid[player.swap_info.to_x, player.swap_info.to_y - 1] = temp;
                    }
        
                    // Reset offsets
                    player.grid[player.swap_info.from_x, player.swap_info.from_y].offset_x = 0;
                    player.grid[player.swap_info.from_x, player.swap_info.from_y].offset_y = 0;
                    player.grid[player.swap_info.to_x,   player.swap_info.to_y].offset_x   = 0;
                    player.grid[player.swap_info.to_x,   player.swap_info.to_y].offset_y   = 0;
        
                    player.swap_in_progress = false;
                } else {
                    // Animate the swap
                    var distance = gem_size * player.swap_info.progress;
        
                    if (player.swap_info.from_x < player.swap_info.to_x) {
                        player.grid[player.swap_info.from_x, player.swap_info.from_y].offset_x =  distance;
                        player.grid[player.swap_info.to_x,     player.swap_info.to_y].offset_x = -distance;
                    } else if (player.swap_info.from_x > player.swap_info.to_x) {
                        player.grid[player.swap_info.from_x, player.swap_info.from_y].offset_x = -distance;
                        player.grid[player.swap_info.to_x,     player.swap_info.to_y].offset_x =  distance;
                    }
                    if (player.swap_info.from_y < player.swap_info.to_y) {
                        player.grid[player.swap_info.from_x, player.swap_info.from_y].offset_y =  distance;
                        player.grid[player.swap_info.to_x,     player.swap_info.to_y].offset_y = -distance;
                    } else if (player.swap_info.from_y > player.swap_info.to_y) {
                        player.grid[player.swap_info.from_x, player.swap_info.from_y].offset_y = -distance;
                        player.grid[player.swap_info.to_x,   player.swap_info.to_y].offset_y   =  distance;
                    }
                }
            }
        }
        
        //function create_swap_info()
        //{
            //var swap_info = 
            //{
                //from_x: -1, 
                //from_y: -1, 
                //to_x: -1, 
                //to_y: -1,
                //progress: 0, 
                //speed: 0.1
            //}
            //
            //return swap_info;
        //}
        
        function create_swap_queue()
        {
            var swap_queue = { 
                active: false, 
                ax: -1, 
                ay: -1, 
                bx: -1, 
                by: -1 
                };
            
            return swap_queue;
        }
