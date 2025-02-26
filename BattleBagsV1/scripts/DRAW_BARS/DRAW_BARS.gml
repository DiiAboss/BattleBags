function draw_percent_bar_primatives(amount, max_amount, start_x, start_y, bar_width = 256, bar_height = 16, fg_color = c_green, bg_color = c_red)
{
    var percent = (amount / max_amount);
    
    // Set the draw backwards slightly
    var bar_x_start = start_x - (bar_width * 0.5);
    var bar_y_start = start_y;
    
    var bg_bar_x_end = bar_x_start + bar_width;
    var bg_bar_y_end = bar_x_start + bar_height;
    
    var fg_bar_x_end = bar_x_start + (bar_width * percent);
    var fg_bar_y_end = bar_y_start + bar_height;
    
    draw_rectangle_color(bar_x_start, bar_y_start, bg_bar_x_end, bg_bar_y_end, bg_color, bg_color, bg_color, bg_color, false);
    draw_rectangle_color(bar_x_start, bar_y_start, fg_bar_x_end, fg_bar_y_end, fg_color, fg_color, fg_color, fg_color, false);
}

function draw_percent_bar_sprites(amount, max_amount, start_x, start_y, bar_width = 256, bar_height = 16, fg_sprite = noone, bg_sprite = noone)
{
    var percent = (amount / max_amount);
    
    // Set the draw backwards slightly
    var bar_x_start = start_x - (bar_width * 0.5);
    var bar_y_start = start_y;
    
    var bg_bar_x_end = bar_x_start + bar_width;
    var bg_bar_y_end = bar_x_start + bar_height;
    
    var fg_bar_x_end = bar_x_start + (bar_width * percent);
    var fg_bar_y_end = bar_y_start + bar_height;
    
}