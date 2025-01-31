function calculate_match_points(_self, match_size) {
	var combo = _self.combo;
    if (match_size == 3) return 10 * combo;
    if (match_size == 4) return 25 * combo;
    if (match_size == 5) return 50 * combo;
    if (match_size > 5) return (50 + ((match_size - 5) * 50)) * combo;
    return 0;
}