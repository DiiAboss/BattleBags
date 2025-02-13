/// @description
if (console_active) {
    draw_set_alpha(console_alpha);
    draw_set_color(c_white);
    draw_rectangle(console_x, console_y, console_x + console_width, console_y + console_height, false);
    draw_set_alpha(1);

    // Draw Console Text
    draw_set_color(c_black);
    //draw_set_font(console_font);
    draw_text(console_x + 10, draw_y_start + console_y + 10, "> " + console_input);

    // Draw Command History
    for (var i = 0; i < min(array_length(console_history), max_history); i++) {
        draw_text(console_x + 10, draw_y_start + console_y + 30 + (i * 20), console_history[i]);
    }
}