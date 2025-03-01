/// @description
// Draw GUI Event
if (show_connection_status) {
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(10, 10, string_width(connection_message) + 30, 40, false);
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_text(20, 20, connection_message);
}