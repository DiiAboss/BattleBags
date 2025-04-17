// ========= DRAW GUI EVENT =========
/// @description Draw objectives UI
draw_set_font(fnt_basic);

// Draw each stack
for (var s = 0; s < array_length(objective_stacks); s++) {
    if (!stack_unlocked[s]) continue;
    
    // Calculate stack position with offsets and shake
    // Stacking vertically instead of horizontally
    var stack_x = objective_base_x + stack_x_offsets[s] + random_range(-current_shake, current_shake);
    var stack_y = objective_base_y + (s * objective_spacing * 6) + stack_y_offsets[s] + random_range(-current_shake, current_shake);
    
    // Draw the current active objective in the stack
    var active_idx = active_objectives[s];
    if (active_idx != -1 && active_idx < array_length(objective_stacks[s])) {
        var obj = objective_stacks[s][active_idx];
        
        // Calculate animated scale if completed
        var scale = obj.animation.scale;
        var scaled_width = panel_width * scale;
        var scaled_height = panel_height * scale;
        var scaled_x = stack_x + (panel_width - scaled_width) / 2;
        var scaled_y = stack_y + (panel_height - scaled_height) / 2;
        
        // Draw background for panel
        draw_set_alpha(0.65);
        
        // Determine panel color based on objective level
        var panel_color1, panel_color2;
        switch (obj.level) {
            case OBJECTIVE_LEVEL.LEVEL_1:
                panel_color1 = c_navy;
                panel_color2 = c_black;
                break;
            case OBJECTIVE_LEVEL.LEVEL_2:
                panel_color1 = make_color_rgb(75, 0, 130); // Indigo
                panel_color2 = c_black;
                break;
            case OBJECTIVE_LEVEL.LEVEL_3:
                panel_color1 = make_color_rgb(128, 0, 128); // Purple
                panel_color2 = c_black;
                break;
            case OBJECTIVE_LEVEL.LEVEL_4:
                panel_color1 = make_color_rgb(178, 34, 34); // Firebrick
                panel_color2 = c_black;
                break;
        }
        
        // If completed, add golden glow
        if (obj.completed) {
            panel_color1 = merge_color(panel_color1, c_yellow, obj.animation.complete_flash);
            panel_color2 = merge_color(panel_color2, c_yellow, obj.animation.complete_flash * 0.5);
        }
        
        draw_roundrect_color(
            scaled_x, scaled_y,
            scaled_x + scaled_width, scaled_y + scaled_height,
            panel_color1, panel_color2, false
        );
        draw_set_alpha(1.0);
        
        // Draw border around panel
        draw_roundrect(
            scaled_x, scaled_y,
            scaled_x + scaled_width, scaled_y + scaled_height,
            true
        );
        
        // Draw objective sprite if available
        if (obj.sprite != spr_none) {
            var spr_x = scaled_x + 32;
            var spr_y = scaled_y + panel_height / 2;
            draw_sprite(obj.sprite, 0, spr_x, spr_y);
        }
        
        // Draw objective details
        draw_set_font(fnt_basic);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        
        // Set text position for title and description
        var text_x = scaled_x + scaled_width / 2;
        var current_y = scaled_y + panel_padding;
        
        // Draw level indicator (stars based on level)
        var level_text = "";
        for (var l = 0; l < obj.level; l++) {
            level_text += "★";
        }
        draw_text(text_x, current_y, level_text);
        current_y += 20;
        
        // Prepare title and description texts
        var objective_text = "";
        var description_text = "";
        
        switch (obj.type) {
            case OBJECTIVE_TYPE.BREAK_COLOR:
                objective_text = "Break " + string(obj.target) + " " + block_name(obj.data) + " Blocks";
                description_text = "Destroy blocks of color " + block_name(obj.data);
                break;
                
            case OBJECTIVE_TYPE.GET_COMBO:
                objective_text = "Reach " + string(obj.target) + "x Combo";
                description_text = "Achieve a combo of " + string(obj.target) + " or higher";
                break;
                
            case OBJECTIVE_TYPE.MATCH_SIZE:
                if (obj.level == OBJECTIVE_LEVEL.LEVEL_4 && obj.data >= 7) {
                    objective_text = "Match " + string(obj.target) + " sets of " + string(obj.data) + "+ Blocks";
                    description_text = "Create " + string(obj.target) + " matches with at least " + string(obj.data) + " blocks each";
                } else {
                    objective_text = "Match " + string(obj.target) + "+ Blocks";
                    description_text = "Create a match of at least " + string(obj.target) + " blocks";
                }
                break;
                
            case OBJECTIVE_TYPE.CLEAR_LINES:
                objective_text = "Clear " + string(obj.target) + " Lines";
                description_text = "Fully clear rows from the board";
                break;
                
            case OBJECTIVE_TYPE.MATCHES_IN_MOVES:
                objective_text = "Make " + string(obj.target) + " Matches";
                description_text = "In " + string(obj.data) + " moves or less";
                break;
                
            case OBJECTIVE_TYPE.KEEP_BELOW_ROW:
                objective_text = "Keep Blocks Low";
                description_text = "Stay below row " + string(obj.data) + " for " + string(obj.target) + " cycles";
                break;
                
            case OBJECTIVE_TYPE.MATCH_SPECIAL:
                objective_text = "Match " + string(obj.target) + " " + block_name(obj.data) + " Blocks";
                description_text = "Create matches including " + block_name(obj.data) + " blocks";
                break;
                
            case OBJECTIVE_TYPE.DESTROY_SPECIAL:
                objective_text = "Destroy " + string(obj.target) + " " + block_name(obj.data) + " Blocks";
                description_text = "Clear special " + block_name(obj.data) + " blocks from board";
                break;
                
            case OBJECTIVE_TYPE.COMBO_IN_MOVES:
                objective_text = "Get " + string(obj.target) + "x Combo";
                description_text = "In " + string(obj.data) + " moves or less";
                break;
                
            case OBJECTIVE_TYPE.TIMED_CHALLENGE:
                objective_text = "Survive";
                description_text = "For " + string(obj.target) + " seconds";
                break;
        }
        
        // Draw objective title clearly
        draw_text(text_x, current_y, objective_text);
        current_y += 24;
        
        // Draw smaller description text (grey for clarity)
        draw_set_color(c_gray);
        draw_text(text_x, current_y, description_text);
        current_y += 24;
        
        // Show EP reward
        draw_set_color(c_lime);
        draw_text(text_x, current_y, "+" + string(obj.ep) + " EP");
        current_y += 24;
        
        // For move-limited objectives, show moves left
        if (obj.type == OBJECTIVE_TYPE.MATCHES_IN_MOVES || obj.type == OBJECTIVE_TYPE.COMBO_IN_MOVES) {
            var moves_used = game_control.moves - obj.moves_start;
            var moves_left = max(0, obj.data - moves_used);
            
            draw_set_color(moves_left <= 3 ? c_red : c_white);
            draw_text(text_x, current_y, "Moves left: " + string(moves_left));
            current_y += 20;
        }
        
        // Progress bar background
        var bar_width = scaled_width - panel_padding * 2;
        var bar_height = 10;
        var bar_x = scaled_x + panel_padding;
        var bar_y = scaled_y + scaled_height - panel_padding - bar_height - 10;
        draw_set_color(c_black);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);
        
        // Progress bar fill (colored based on completion)
        var progress_color = obj.completed ? c_lime : c_yellow;
        var progress_percent = clamp(obj.progress / obj.target, 0, 1);
        draw_set_color(progress_color);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width * progress_percent, bar_y + bar_height, false);
        
        // Numeric progress text (centered)
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(bar_x + bar_width / 2, bar_y + bar_height / 2, string(obj.progress) + "/" + string(obj.target));
    }
}

// Draw event objectives if active
if (current_event != EVENT_TYPE.NONE) {
    // Position event objectives below regular objectives
    var event_x = objective_base_x;
    var event_y = objective_base_y + (max_stacks * objective_spacing * 6) + 20;
    
    // Draw event header
    var event_title = "";
    switch (current_event) {
        case EVENT_TYPE.BUG_SWARM: event_title = "BUG SWARM"; break;
        case EVENT_TYPE.COLD_SNAP: event_title = "COLD SNAP"; break;
        case EVENT_TYPE.LOOSE_GROUND: event_title = "LOOSE GROUND"; break;
        case EVENT_TYPE.MINOR_BATTLE: event_title = "MINOR BATTLE"; break;
    }
    
    // Draw event background
    var event_width = panel_width + 40;
    var event_height = (panel_height + objective_spacing) * array_length(event_objectives) + 60;
    
    // Pulsing effect for event
    var alpha_pulse = 0.3 + sin(current_time * 0.005) * 0.1;
    draw_set_alpha(alpha_pulse);
    
    // Color based on event type
    var event_color;
    switch (current_event) {
        case EVENT_TYPE.BUG_SWARM: event_color = c_lime; break;
        case EVENT_TYPE.COLD_SNAP: event_color = c_aqua; break;
        case EVENT_TYPE.LOOSE_GROUND: event_color = c_orange; break;
        case EVENT_TYPE.MINOR_BATTLE: event_color = c_red; break;
        default: event_color = c_white; break;
    }
    
    // Draw event panel
    draw_roundrect_color(
        event_x - 20, event_y - 40,
        event_x + event_width, event_y + event_height,
        event_color, event_color, false
    );
    draw_set_alpha(1.0);
    
    // Draw event title and timer
    draw_set_halign(fa_center);
    draw_set_color(c_black);
    draw_text(event_x + panel_width / 2, event_y - 25, event_title);
    
    // Draw event timer
    var time_left = max(0, (event_duration - (current_time - event_start_time)) / 1000);
    draw_text(event_x + panel_width / 2, event_y + event_height - 25, "Time: " + string(ceil(time_left)) + "s");
    
    // Draw event objectives
    for (var i = 0; i < array_length(event_objectives); i++) {
        var obj = event_objectives[i];
        var obj_y = event_y + (panel_height + objective_spacing) * i;
        
        // Draw panel for this objective
        draw_set_alpha(0.95);
        
        // Use dark color for event objective panels
        var panel_color1 = merge_color(c_black, event_color, 0.3);
        var panel_color2 = c_black;
        
        // Golden glow when completed
        if (obj.completed) {
            panel_color1 = merge_color(panel_color1, c_yellow, obj.animation.complete_flash);
        }
        
        draw_roundrect_color(
            event_x, obj_y,
            event_x + panel_width, obj_y + panel_height,
            panel_color1, panel_color2, false
        );
        draw_set_alpha(1.0);
        
        // Draw border
        draw_roundrect(
            event_x, obj_y,
            event_x + panel_width, obj_y + panel_height,
            true
        );
        
        // Draw objective content (similar to regular objectives)
        // Rest of drawing code for event objectives is similar...
        // [Drawing code for event objectives - similar to regular objectives]
        
        // Draw objective details
        draw_set_font(fnt_basic);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        
        // Set text position for title and description
        var text_x = event_x + panel_width / 2;
        var current_y = obj_y + panel_padding;
        
        // Prepare title and description texts
        var objective_text = "";
        var description_text = "";
        
        switch (obj.type) {
            case OBJECTIVE_TYPE.BREAK_COLOR:
                objective_text = "Break " + string(obj.target) + " " + block_name(obj.data) + " Blocks";
                description_text = "Destroy blocks of color " + block_name(obj.data);
                break;
                
            case OBJECTIVE_TYPE.GET_COMBO:
                objective_text = "Reach " + string(obj.target) + "x Combo";
                description_text = "Achieve a combo of " + string(obj.target) + " or higher";
                break;
                
            case OBJECTIVE_TYPE.MATCH_SIZE:
                objective_text = "Match " + string(obj.target) + "+ Blocks";
                description_text = "Create a match of at least " + string(obj.target) + " blocks";
                break;
                
            case OBJECTIVE_TYPE.MATCH_SPECIAL:
                objective_text = "Match " + string(obj.target) + " " + block_name(obj.data) + " Blocks";
                description_text = "Create matches including " + block_name(obj.data) + " blocks";
                break;
                
            case OBJECTIVE_TYPE.DESTROY_SPECIAL:
                objective_text = "Destroy " + string(obj.target) + " " + block_name(obj.data) + " Blocks";
                description_text = "Clear special " + block_name(obj.data) + " blocks from board";
                break;
                
            case OBJECTIVE_TYPE.TIMED_CHALLENGE:
                objective_text = "Survive";
                description_text = "For " + string(obj.target) + " seconds";
                break;
                
            // Add other event objective types as needed
        }
        
        // Draw objective title clearly
        draw_text(text_x, current_y, objective_text);
        current_y += 24;
        
        // Draw smaller description text
        draw_set_color(c_gray);
        draw_text(text_x, current_y, description_text);
        current_y += 24;
        
        // Show EP reward
        draw_set_color(c_lime);
        draw_text(text_x, current_y, "+" + string(obj.ep) + " EP");
        current_y += 24;
        
        // Progress bar background
        var bar_width = panel_width - panel_padding * 2;
        var bar_height = 10;
        var bar_x = event_x + panel_padding;
        var bar_y = obj_y + panel_height - panel_padding - bar_height - 10;
        draw_set_color(c_black);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);
        
        // Progress bar fill
        var progress_color = obj.completed ? c_lime : c_yellow;
        var progress_percent = clamp(obj.progress / obj.target, 0, 1);
        draw_set_color(progress_color);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width * progress_percent, bar_y + bar_height, false);
        
        // Numeric progress text
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(bar_x + bar_width / 2, bar_y + bar_height / 2, string(obj.progress) + "/" + string(obj.target));
    }
}

// Draw bonus EP notification if active
if (show_bonus_notification) {
    var notification_x = display_get_gui_width() / 2;
    var notification_y = display_get_gui_height() / 3;
    var time_since = current_time - bonus_notification_time;
    var alpha = min(1, (3000 - time_since) / 500);
    
    draw_set_alpha(alpha);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_basic);
    
    // Create animation effect
    var scale = 1 + sin(time_since * 0.01) * 0.2;
    var bonus_text = "BONUS EP: +" + string(bonus_ep);
    
    // Draw glowing text
    draw_set_color(c_black);
    for (var j = -2; j <= 2; j += 2) {
        for (var k = -2; k <= 2; k += 2) {
            draw_text_transformed(notification_x + j, notification_y + k, bonus_text, scale, scale, 0);
        }
    }
    
    // Draw main text
    draw_set_color(c_yellow);
    draw_text_transformed(notification_x, notification_y, bonus_text, scale, scale, 0);
    
    // Additional context
    draw_set_color(c_white);
    draw_text(notification_x, notification_y + 30 * scale, "Milestone: " + string(completed_objectives) + " objectives completed!");
    
    draw_set_alpha(1.0);
}

// Reset drawing settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
    
    