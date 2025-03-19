// Script Created By DiiAboss AKA Dillon Abotossaway
/// @function hover_draw(_self, max)
/// @description Draws the object sprite with a vertical hovering motion
function hover_draw(_max) {
    var hover_offset = sin(current_time * 0.005) * _max; // smoothly oscillates based on current time
    return hover_offset;
}