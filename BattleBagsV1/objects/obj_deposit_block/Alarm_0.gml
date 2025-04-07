/// @description




if (rotation_speed == 0)
{
    
    var destroyed = destroy_deposit_matches(self);
    // Check if we have enough blocks destroyed to trigger the push effect
    if (destroyed.total_destroyed >= 3) {
        // Create a push effect at the position of the last destroyed block
        var player = obj_game_control;
        player.energy_points += destroyed.total_destroyed;
        player.combo += 1;
        create_push_effect(x, y, destroyed.total_destroyed * 5);
        show_debug_message(string(destroyed));
    }
    
}




alarm[0] = check_for_match;

