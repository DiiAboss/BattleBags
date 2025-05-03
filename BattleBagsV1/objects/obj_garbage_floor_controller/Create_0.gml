/// @description Create perfect isometric grid
/// Place this in a controller object's Create event

// Dimensions of obj_garbage_floor
var tile_width = 64;
var tile_height = 64;

// EXACT isometric spacing - these values are critical!
var x_offset = tile_width;      // Full tile width for X spacing
var y_offset = tile_height/2;   // Half tile height for Y spacing

// Calculate needed coverage
var margin = 400;

// Starting position (centered in room)
var center_x = room_width/2;
var center_y = room_height/2;

// Create the isometric grid with perfect spacing
for (var ix = -30; ix < 30; ix++) {
    for (var iy = -30; iy < 30; iy++) {
        // Calculate true isometric position (diamond grid)
        var pos_x = center_x + (ix * x_offset/2) - (iy * x_offset/2);
        var pos_y = center_y + (ix * y_offset) + (iy * y_offset);
        
        // Only create tiles in or near the visible room
        if (pos_x > -margin && pos_x < room_width + margin && 
            pos_y > -margin && pos_y < room_height + margin) {
            instance_create_layer(pos_x, pos_y, "Instances", obj_garbage_floor);
        }
    }
}