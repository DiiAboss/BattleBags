/// Returns true if top row contains a gem and none are falling
function is_top_row_filled(_self) {
	
	var width = _self.width;
	
    for (var i = 0; i < width; i++) {
        var gem = grid[i, 0];
        
        // ✅ If there's a valid gem in row 0
        if (gem.type != -1) {
            // ✅ If it's still falling, return **false**
            if (gem.falling) return false; 
        }
    }
    return true; // ✅ All gems are stationary in row 0
}