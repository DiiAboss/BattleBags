// ========= STEP EVENT =========
/// @description Update objectives and events
// Skip updates when paused
if (global.paused) exit;

// Update animation properties
current_shake *= 0.9; // Decay shake

// Update stack animations
for (var s = 0; s < array_length(stack_x_offsets); s++) {
    stack_x_offsets[s] *= 0.9;
    stack_y_offsets[s] *= 0.9;
}

// Update stacks that need advancement
for (var s = 0; s < array_length(stack_needs_update); s++) {
    if (stack_needs_update[s]) {
        var time_since_completion = current_time - update_stack_timer[s];
        
        // If enough time has passed since completion, advance to next objective
        if (time_since_completion >= stack_update_delay) {
            advance_stack_objective(s);
            stack_needs_update[s] = false;
        }
    }
}

// Update active objectives
for (var s = 0; s < array_length(objective_stacks); s++) {
    if (!stack_unlocked[s]) continue;
    
    var active_idx = active_objectives[s];
    if (active_idx != -1 && active_idx < array_length(objective_stacks[s])) {
        objective_stacks[s][active_idx].update();
    }
}

// Update event objectives
for (var i = 0; i < array_length(event_objectives); i++) {
    event_objectives[i].update();
}

// Update event timers
if (current_event != EVENT_TYPE.NONE) {
    var time_elapsed = current_time - event_start_time;
    if (time_elapsed > event_duration) {
        end_event();
    }
}

    // Check for combo objective progress
if (game_control.combo > 1) {
    objective_progress(OBJECTIVE_TYPE.GET_COMBO, undefined, game_control.combo);
    
    // Also check for combo in moves objectives
    objective_progress(OBJECTIVE_TYPE.COMBO_IN_MOVES, undefined, game_control.combo);
}

// Update notification timers
if (show_bonus_notification) {
    if (current_time - bonus_notification_time > 3000) { // Show for 3 seconds
        show_bonus_notification = false;
    }
}
