/// Returns true if top row contains a gem and none are falling
function is_top_row_filled(_self) {
	
	var width = _self.width;
	
    for (var i = 0; i < width; i++) {
		for (var j = 0; j < _self.top_playable_row; j++)
		{
	        var gem = grid[i, j];
        
	        // ✅ If there's a valid gem in row 0
	        if (gem.type != -1) {
	            // ✅ If it's still falling, return **false**
	            if (gem.falling) return false; 
			}
        }
    }
    return true; // ✅ All gems are stationary in row 0
}