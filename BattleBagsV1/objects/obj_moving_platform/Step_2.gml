// END STEP EVENT - Make sure to create a separate End Step event in GameMaker
/// @description End Step
// Check for player on top of platform
if (instance_exists(obj_player_drone)) {
    var player = instance_find(obj_player_drone, 0);
    
    // Check if player is directly above the platform
    if (player.can_jump && 
        collision_rectangle(bbox_left, bbox_top - 4, bbox_right, bbox_top + 4, player, false, true)) {
        
        // Player is on the platform
        has_rider = true;
        
        // Apply platform movement to player
        if (last_h_move != 0) player.x += last_h_move;
        if (last_v_move != 0) player.y += last_v_move;
    }
}
