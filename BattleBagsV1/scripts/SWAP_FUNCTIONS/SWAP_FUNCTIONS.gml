
// Script Created By DiiAboss AKA Dillon Abotossaway
///@function start_swap
///
///@description Initiates a swap between two gems while ensuring valid swap conditions.
///
///@param {id} _self - The game object managing the board.
///@param {real} ax - The x-coordinate of the first gem.
///@param {real} ay - The y-coordinate of the first gem.
///@param {real} bx - The x-coordinate of the second gem.
///@param {real} by - The y-coordinate of the second gem.
///
function start_swap(_self, ax, ay, bx, by) {
    if (_self.swap_in_progress) return; // Prevent stacking swaps

    // ✅ Ensure swap is within playable area
    if (ay < top_playable_row || ay > bottom_playable_row ||
        by < top_playable_row || by > bottom_playable_row) return;

    var gemA = _self.grid[ax, ay];
    var gemB = _self.grid[bx, by];

    // ✅ Prevent swapping `big` blocks if they belong to different groups
    if (gemA.is_big || gemB.is_big) {
        if (gemA.group_id != gemB.group_id) return;
        var parentA = gemA.big_parent;
        var parentB = gemB.big_parent;

        if (parentA[0] != parentB[0] || parentA[1] != parentB[1]) return; // Ensure swapping whole block
    }

    // ✅ Execute the swap normally if no shifting is happening
    execute_swap(_self, ax, ay, bx, by);
}



// Script Created By DiiAboss AKA Dillon Abotossaway
///@function execute_swap
///
///@description Executes a swap between two gems, handling special cases like shifting and frozen blocks.
///
///@param {struct} _self - The game object managing the board.
///@param {real} ax - The x-coordinate of the first gem.
///@param {real} ay - The y-coordinate of the first gem.
///@param {real} bx - The x-coordinate of the second gem.
///@param {real} by - The y-coordinate of the second gem.
///
function execute_swap(_self, ax, ay, bx, by) {
    var width = _self.width;
    var height = _self.height;

    // ✅ Validate swap positions (ensures within grid bounds)
    if (
        ax < 0 || ax >= width || ay < 0 || ay >= height ||
        bx < 0 || bx >= width || by < 0 || by >= height
    ) return;

    // ✅ Prevent swapping if one of the gems is being destroyed
    if (is_being_destroyed(ax, ay) || is_being_destroyed(bx, by)) return;

    // ✅ Prevent swapping frozen blocks
    if (_self.grid[ax, ay].frozen || _self.grid[bx, by].frozen) return;

    // ✅ Prevent swapping MEGA blocks
    if (_self.grid[ax, ay].type == BLOCK.MEGA || _self.grid[bx, by].type == BLOCK.MEGA) return;

    // 🔹 Handle row shifting logic
    if (_self.global_y_offset == 0) {
        _self.swap_info.from_x = ax;
        _self.swap_info.from_y = ay - 1;  // ✅ Adjusting swap to account for shifting
        _self.swap_info.to_x   = bx;
        _self.swap_info.to_y   = by - 1;
        _self.swap_info.progress = 0;
    }
    else
    {
        _self.swap_in_progress = true;
        _self.swap_info.from_x = ax;
        _self.swap_info.from_y = ay;
        _self.swap_info.to_x   = bx;
        _self.swap_info.to_y   = by;
        _self.swap_info.progress = 0;
        _self.swap_info.speed = 0.15;
    }
}
