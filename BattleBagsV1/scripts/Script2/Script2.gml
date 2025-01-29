// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
//function spawn_new_row(width, height, grid) {
//    // Shift all gems up by 1 row
//    for (var i = 0; i < width; i++) {
//        for (var j = height - 2; j >= 0; j--) {
//            grid[i, j + 1] = grid[i, j]; // Move gems up
//        }
//    }
    
//    // Spawn a new row at the bottom
//    for (var i = 0; i < width; i++) {
//        grid[i, 0] = irandom(4); // Spawn random gem types at the bottom
//    }
//}

function spawn_new_row(width, height, grid) {
    for (var i = 0; i < width; i++) {
        grid[i, height - 1] = irandom(numberOfGemTypes);
        gem_y_offsets[i, height - 1] = gem_size;
    }
}