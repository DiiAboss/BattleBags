
// Script Created By DiiAboss AKA Dillon Abotossaway
///@function start_swap
///
///@description Initiates a swap between two gems while ensuring valid swap conditions.
///
///@param {id} player - The game object managing the board.
///@param {real} ax - The x-coordinate of the first gem.
///@param {real} ay - The y-coordinate of the first gem.
///@param {real} bx - The x-coordinate of the second gem.
///@param {real} by - The y-coordinate of the second gem.
///
function start_swap(player, ax, ay, bx, by) {
    if (player.swap_in_progress) return; // Prevent stacking swaps
    
    var top_row      = player.top_playable_row;
    var bottom_row   = player.bottom_playable_row;
    
    // ✅ Ensure swap is within playable area
    if (ay < top_row || ay > bottom_row ||
        by < top_row || by > bottom_row) return;

    var block_a = player.grid[ax, ay];
    var block_b = player.grid[bx, by];
    var type_a = block_a.type;
    var type_b = block_b.type;
    
    
    // ✅ Prevent swapping `big` blocks if they belong to different groups
    if (block_a.is_big || block_b.is_big) {
        if (block_a.group_id != block_b.group_id) return;
        var parent_a = block_a.big_parent;
        var parent_b = block_b.big_parent;

        if (parent_a[0] != parent_b[0] || parent_a[1] != parent_b[1]) return; // Ensure swapping whole block
    }
    if (block_a.frozen || block_b.frozen) return;
        
    if (block_a.offset_y != block_b.offset_y) return;
    
    // ✅ Execute the swap normally if no shifting is happening
    execute_swap(player, ax, ay, bx, by);
    
    var target_type = BLOCK.COLOR_BOMB;
        if (type_a != BLOCK.NONE && type_b != BLOCK.NONE)
            if (type_a == BLOCK.COLOR_BOMB || type_b == BLOCK.COLOR_BOMB)
            {
                if type_a == BLOCK.COLOR_BOMB && type_b == BLOCK.COLOR_BOMB
                {
                    var height       = player.bottom_playable_row;
                    var width        = player.board_width;
                    var grid         = player.grid;
                    var topmost_row  = player.top_playable_row;
                    
                    for (var i = height; i > topmost_row; i--)
                    {
                        for (var j = 0; j < width; j++)
                            {
                            var gem = grid[j, i]
                            if (gem.type == BLOCK.NONE) continue;
                            // ✅ Send the block to pop_list (Now applies to normal and transformed blocks)
                            var pop_info = {
                                x: j,
                                y: i,
                                gem_type: gem.type,
                                timer: 0,
                                start_delay: i * j, // Wave effect
                                scale: 1.0,
                                popping: true,
                                powerup: gem.powerup,
                                dir: gem.dir,
                                offset_x: gem.offset_x,
                                offset_y: gem.offset_y,
                                color: gem.color,
                                y_offset_global: player.global_y_offset,
                                match_size: 1, // ✅ Store the match size
                                match_points: 1000,
                                bomb_tracker: false, // Flag to mark this pop as bomb‐generated
                                bomb_level: 0,
                                img_number: gem.img_number,
                                is_big: false,
                            };
                        
                            player.grid[j, i].popping   = true;
                            player.grid[j, i].pop_timer = i * j;
                            ds_list_add(player.pop_list, pop_info);
                        }
                    }
                    destroy_block(player, ax, ay);
                    destroy_block(player, bx, by);
                    return;  
                }
                
                if (type_a) == BLOCK.COLOR_BOMB
                {
                    target_type = type_b;
                    player.grid[ax, ay].type = target_type;
                    player.grid[ax, ay].cb   = target_type;
                    //_self.grid[ax, ay].popping   = true;
                }
                if (type_b) == BLOCK.COLOR_BOMB {
                    target_type = type_a;
                    player.grid[bx, by].type = target_type;
                    player.grid[bx, by].cb   = target_type;
                    //_self.grid[bx, by].popping   = true;
                }
                
                
            }

}


function process_swap(player)
{
    if (player.swap_queue.active) && !player.swap_in_progress //(player.global_y_offset - player.shift_speed > -player.gem_size)
    {
        player.swap_in_progress = execute_swap(player, player.swap_queue.ax, player.swap_queue.ay, player.swap_queue.bx, player.swap_queue.by);
        player.swap_queue.active = false; // Clear the swap queue
        return;
    }
    
    
    
    
    
    var swap_info = player.swap_info;
	if (player.swap_in_progress) {
	    player.swap_info.progress += player.swap_info.speed;
        
        //show_debug_message("swap_info progress: " + string(swap_info.progress));
        //show_debug_message("player.swap_info progress: " + string(player.swap_info.progress));
	    if (swap_info.progress >= 1) {
	        swap_info.progress = 1;
            player.swap_info.progress = 1;
            

            var temp = player.grid[swap_info.from_x, swap_info.from_y];
            player.grid[swap_info.from_x, swap_info.from_y] = player.grid[swap_info.to_x, swap_info.to_y];
            player.grid[swap_info.to_x, swap_info.to_y] = temp;


	        // Reset offsets
	        player.grid[swap_info.from_x, swap_info.from_y].offset_x = 0;
	        player.grid[swap_info.from_x, swap_info.from_y].offset_y = 0;
	        player.grid[swap_info.to_x,   swap_info.to_y].offset_x   = 0;
	        player.grid[swap_info.to_x,   swap_info.to_y].offset_y   = 0;

            if player.grid[swap_info.from_x, swap_info.from_y].cb != BLOCK.NONE
            {
                destroy_blocks_of_color(player, player.grid[swap_info.from_x, swap_info.from_y].cb);
            }
            if player.grid[swap_info.to_x,   swap_info.to_y].cb != BLOCK.NONE
            {
                destroy_blocks_of_color(player, player.grid[swap_info.to_x,   swap_info.to_y].cb);
            }
	        player.swap_in_progress = false;
	    } else {
	        // Animate the swap
            //show_debug_message("else swap_info progress: " + string(swap_info.progress));
	        var distance = player.gem_size * swap_info.progress;
            
	        if (swap_info.from_x < swap_info.to_x) {
	            player.grid[swap_info.from_x, swap_info.from_y].offset_x =  distance;
	            player.grid[swap_info.to_x,     swap_info.to_y].offset_x = -distance;
	        } else if (swap_info.from_x > swap_info.to_x) {
	            player.grid[swap_info.from_x, swap_info.from_y].offset_x = -distance;
	            player.grid[swap_info.to_x,     swap_info.to_y].offset_x =  distance;
	        }
	        if (swap_info.from_y < swap_info.to_y) {
	            player.grid[swap_info.from_x, swap_info.from_y].offset_y =  distance;
	            player.grid[swap_info.to_x,     swap_info.to_y].offset_y = -distance;
	        } else if (swap_info.from_y > swap_info.to_y) {
	            player.grid[swap_info.from_x, swap_info.from_y].offset_y = -distance;
	            player.grid[swap_info.to_x,   swap_info.to_y].offset_y   =  distance;
	        }
            //show_debug_message("blockA offset: " + string(player.grid[swap_info.from_x, swap_info.from_y].offset_x));
            //show_debug_message("blockB offset: " + string(player.grid[swap_info.to_x,     swap_info.to_y].offset_x));
	    }
        //player.swap_info = swap_info;
	}
}

function create_swap_info()
{
	var swap_info = 
	{
		from_x: -1, 
		from_y: -1, 
		to_x: -1, 
		to_y: -1,
	    progress: 0, 
		speed: 0.1
	}
	
	return swap_info;
}

// Script Created By DiiAboss AKA Dillon Abotossaway
///@function execute_swap
///
///@description Executes a swap between two gems, handling special cases like shifting and frozen blocks.
///
///@param {struct} player - The game object managing the board.
///@param {real} ax - The x-coordinate of the first gem.
///@param {real} ay - The y-coordinate of the first gem.
///@param {real} bx - The x-coordinate of the second gem.
///@param {real} by - The y-coordinate of the second gem.
///
function execute_swap(player, ax, ay, bx, by) {
    var width  = player.board_width;
    var height = player.board_height;

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
	}
	
    var block_a = player.grid[ax, ay];
    var block_b = player.grid[bx, by];
    
    if (block_a.offset_y != block_b.offset_y) return false;
    
    // set both blocks to not fall while swapping
    var falling      = false; //player.grid[ax, ay].falling || player.grid[bx, by].falling; TODO: Find out why this didint work
    var fall_delay   = 5;     //max(player.grid[ax, ay].fall_delay, player.grid[bx, by].fall_delay) TODO: Find out why this didnt work.
    
    player.grid[ax, ay].fall_delay   = fall_delay;
    player.grid[ax, ay].falling      = falling;
    player.grid[bx, by].fall_delay   = fall_delay;
    player.grid[bx, by].falling      = falling;
    
    // ✅ Prevent swapping if one of the gems is being destroyed
    if (is_being_destroyed(player, ax, ay) || is_being_destroyed(player, bx, by)) return false;

    // ✅ Prevent swapping frozen blocks
    if (player.grid[ax, ay].frozen || player.grid[bx, by].frozen) return false;

    // ✅ Prevent swapping MEGA blocks
    if (player.grid[ax, ay].type == BLOCK.MEGA || player.grid[bx, by].type == BLOCK.MEGA) return false;
	
	var _swap_speed = min(player.grid[ax, ay].swap_speed, player.grid[bx, by].swap_speed);

    player.swap_in_progress = true;
    player.swap_info.from_x = ax;
    player.swap_info.from_y = ay;
    player.swap_info.to_x   = bx;
    player.swap_info.to_y   = by;
    player.swap_info.progress = 0;
    player.swap_info.speed = _swap_speed;
    
    return true;
}
