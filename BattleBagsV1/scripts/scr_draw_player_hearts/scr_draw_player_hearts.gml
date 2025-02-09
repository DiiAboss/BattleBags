// Script Created By DiiAboss AKA Dillon Abotossaway
/// @function draw_player_hearts
/// @description Draws player hearts, centered dynamically & resizes if needed.
/// @param {id} _self
/// @param {real} player_health
/// @param {real} max_player_health
/// @param {real} _x - Center X position
/// @param {real} _y - Y position
/// @param {real} width - Max width allowed for hearts
/// @param {real} sprite - Sprite of hearts (default: spr_hearts)
/// @param {real} size - Default heart size (default: 64)
/// @param {real} health_per_heart - Health per heart (default: 4)
function draw_player_hearts(_self, player_health, max_player_health, _x, _y, width, sprite = spr_hearts, size = 64, health_per_heart = 4) {
    
    // Calculate total hearts needed
    var total_hearts = max_player_health div health_per_heart;
    var full_hearts = player_health div health_per_heart;
    var remainder = player_health mod health_per_heart;
    
    // Set max allowed width for hearts
    var max_width = width * size;
    var center_x = _x + (max_width * 0.5) + 32;
	
    // Determine heart size based on spacing
    var heart_spacing = size + 4; // Base spacing
    var total_width = total_hearts * heart_spacing; // Total width of hearts
    var scale = 1.0; // Default scale
    
    // If hearts exceed max width, shrink them
    if (total_width > max_width) {
        scale = max_width / total_width;
        heart_spacing *= scale;
        size *= scale;
    }
    draw_rectangle(_x, _y - 36, _x + (width * size), _y + 80, false);
	draw_set_color(c_black);
	//draw_rectangle(_x, _y - 36, _x + bar_width, bar_y + 4, false);
    // Calculate the **centered starting X position**
    var start_x = center_x - ((total_hearts * heart_spacing) / 2);
    
    // Loop through each heart slot
    for (var i = 0; i < total_hearts; i++) {
        var _sprite_index = 0; // Default empty heart

        if (i < full_hearts) {
            _sprite_index = health_per_heart; // Full heart
        }
        else if (i == full_hearts) {
            _sprite_index = remainder; // Partial heart (1/4, 2/4, 3/4)
        }

        // Draw heart sprite, centered dynamically
        draw_sprite_ext(sprite, _sprite_index, start_x + (i * heart_spacing), _y, scale, scale, 0, c_white, 1);
    }
}
