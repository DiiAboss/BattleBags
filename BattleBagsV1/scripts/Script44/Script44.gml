// Script Created By DiiAboss AKA Dillon Abotossaway
// ✅ Function to mark matches
function mark_match(marked_for_removal, _x, count, _y, _direction) {
    for (var k = 0; k < count; k++) {
        if (_direction == "horizontal") marked_for_removal[_x + k, _y] = true;
        else if (_direction == "vertical") marked_for_removal[_x, _y + k] = true;
    }
}

// ✅ Function to mark diagonal matches
function mark_diagonal_match(marked_for_removal, start_x, start_y, count, _direction) {
    for (var k = 0; k < count; k++) {
        if (_direction == "↘") marked_for_removal[start_x + k, start_y + k] = true;
        else if (_direction == "↙") marked_for_removal[start_x - k, start_y + k] = true;
    }
}