/// @description

/// Objective popups positioning
var panel_x = 32;
var panel_width = 260;
var panel_padding = 10;
var spacing_between_panels = 32;
var line_height = 24;

// Start Y position for stacking vertically
var panel_y_start = 120;

// Loop through each objective to draw separate popup
for (var i = 0; i < array_length(objectives); i++) {
    var obj = objectives[i];
    
    // Panel height calculation for each popup individually
    var panel_height = panel_padding * 3 + line_height * 3;
    var panel_y = panel_y_start + (panel_height + spacing_between_panels) * i;

    // Draw background for individual panel
    draw_set_alpha(0.95);
    draw_roundrect_color(
        panel_x, panel_y,
        panel_x + panel_width, panel_y + panel_height,
        c_navy, c_black, false
    );
    draw_set_alpha(1.0);

    // Draw border around individual panel
    draw_roundrect(
        panel_x, panel_y,
        panel_x + panel_width, panel_y + panel_height,
        true
    );

    // Draw objective title
    draw_set_font(fnt_basic);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    //draw_text(panel_x + panel_width / 2, panel_y + panel_padding, "Objective\n");

    // Set initial text position for title and description
    var text_x = panel_x + panel_width / 2;
    var current_y = panel_y + panel_padding + line_height;

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

        case OBJECTIVE_TYPE.CLEAR_LINES:
            objective_text = "Clear " + string(obj.target) + " Lines";
            description_text = "Fully clear rows from the board";
            break;
    }

    // Draw objective title clearly
    draw_text(text_x, current_y, objective_text);
    current_y += line_height;


    // Draw smaller description text (grey for clarity)
    draw_set_color(c_gray);
    draw_text(text_x, current_y, description_text);
    current_y += line_height;

    // Progress bar background
    var bar_width = panel_width - panel_padding * 2;
    var bar_height = 6;
    var bar_x = panel_x + panel_padding;
    var bar_y = panel_y + panel_padding + 4;//current_y + 4;

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

    // Reset alignments for next popup
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Reset color at end
draw_set_color(c_white);