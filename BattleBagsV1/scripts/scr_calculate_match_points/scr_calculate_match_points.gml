function calculate_match_points(_self, match_size) {
	var combo = _self.combo + 1;
    if (match_size == 3) return 1 + combo;
    if (match_size == 4) return 2 + combo;
    if (match_size == 5) return 3 + combo;
    if (match_size > 5) return (3 + ((match_size - 5) * 3)) * combo;
    return 0;
}