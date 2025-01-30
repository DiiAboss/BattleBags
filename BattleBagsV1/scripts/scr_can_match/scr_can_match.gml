    // Helper function to check match conditions
    function can_match(gem1, gem2) {
        if (!gem1 || !gem2) return false; // Ensure both gems are valid objects
        return gem1.type != -1 && gem2.type != -1 && (
            gem1.type == gem2.type || 
            gem1.type == -2 || 
            gem2.type == -2
        );
    }