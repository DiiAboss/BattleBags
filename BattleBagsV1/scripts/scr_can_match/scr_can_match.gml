    // Helper function to check match conditions
function can_match(gem1, gem2) {
    if (!gem1 || !gem2) return false; // Ensure valid gems

    // ❌ Black blocks can NEVER match (even with other black blocks)
    if (gem1.type == BLOCK.BLACK || gem2.type == BLOCK.BLACK) return false;

    return gem1.type != -1 && gem2.type != -1 && (
        gem1.type == gem2.type ||  // ✅ Normally, matching colors
        gem1.type == BLOCK.WILD || // ✅ Wild block override
        gem2.type == BLOCK.WILD
    );
}