/// @description
// New object: obj_matchmaking_queue
// Create Event
queue_time = 0;
animation_frame = 0;
dots = "";

// Step Event
queue_time += 1;

// Update animation every 30 steps (1 second at 30fps)
if (queue_time mod 30 == 0) {
    animation_frame = (animation_frame + 1) mod 4;
    dots = "";
    for (var i = 0; i < animation_frame; i++) {
        dots += ".";
    }
}

// Check for cancellation
if (keyboard_check_pressed(vk_escape)) {
    // Send cancel matchmaking request
    with (obj_client) {
        var data = ds_map_create();
        ds_map_add(data, "type", DATA_TYPE.CANCEL_MATCHMAKING);
        ds_map_add(data, "playerId", obj_connection_manager.player_id);
        
        send_map_over_UDP(self, data, DATA_TYPE.CANCEL_MATCHMAKING);
    }
    
    // Go back to main menu
    room_goto(rm_multiplayer_selection);
    instance_destroy();
}

// Draw Event
draw_set_color(c_black);
draw_set_alpha(0.8);
draw_rectangle(0, 0, room_width, room_height, false);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_set_alpha(1);

draw_text(room_width/2, room_height/2 - 40, "SEARCHING FOR RANKED MATCH" + dots);
draw_text(room_width/2, room_height/2, "Estimated wait time: " + string(ceil(queue_time/30)) + " seconds");
draw_text(room_width/2, room_height/2 + 40, "Press ESC to cancel");

draw_set_halign(fa_left);
draw_set_valign(fa_top);