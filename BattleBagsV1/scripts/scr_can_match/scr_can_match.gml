// Helper function to check match conditions
function can_match(gem1, gem2) {
    if (!gem1 || !gem2) return false; // Ensure valid gems

    // ❌ Black blocks can NEVER match (even with other black blocks)
    if (gem1.type == BLOCK.BLACK || gem2.type == BLOCK.BLACK) return false;
    if (gem1.type == BLOCK.MEGA || gem2.type == BLOCK.MEGA) return false;
	
    // ❌ **Enemy blocks cannot match until they land**
    if (gem1.is_enemy_block || gem2.is_enemy_block) return false;
	
    if (gem1.type == BLOCK.PUZZLE_1 || gem2.type == BLOCK.PUZZLE_1) return false;
	
		 //✅ 2x2 block handling: Always match by group_id
    if (gem1.is_big || gem2.is_big) {
        if (gem1.group_id == gem2.group_id) return true;
    }


    // ✅ Normal matching conditions
    return gem1.type != -1 && gem2.type != -1 && (
        gem1.type == gem2.type ||  // ✅ Normally, matching colors
        gem1.type == BLOCK.WILD || // ✅ Wild block override
        gem2.type == BLOCK.WILD
    );
}

