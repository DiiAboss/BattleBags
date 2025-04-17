/// @description
/// Travel Tracker - Add to Draw GUI event

if (room == rm_gameRoom)
{
	// Big "white" bar at top of screen
    draw_set_alpha(0.5);
    draw_set_color(c_maroon);
    draw_rectangle(0, 0, window_get_width(), 128, false);
    draw_set_alpha(1);



// Set these values to position your tracker on screen
var tracker_x = 32;                 // X position of the tracker
var tracker_y = 40; // Position near bottom of screen
var tracker_width = display_get_gui_width() - 64; // Full width minus margins
var tracker_height = 16;            // Height of tracker bar
var border_thickness = 2;           // Border thickness
var icon_size = 20;                 // Size of icon markers

// Calculate progress
var total_distance = point_distance(current_run.start_x, current_run.start_y, current_run.target_x, current_run.target_y);
var distance_traveled = total_distance - point_distance(current_run.overworld_x, current_run.overworld_y, current_run.target_x, current_run.target_y);
var progress_percentage = distance_traveled / total_distance;

// Determine if we're in the final 10%
var in_final_stretch = (progress_percentage >= 0.9);

// Create a subtle pulse effect for the bar height only
var original_height = tracker_height;
var pulse_speed = 0.05; // Slower pulse
var pulse_amount = 0.2; // Subtle height pulse

if (in_final_stretch) {
    // Create a subtle pulsing effect on the height only
    var height_scale = 1.0 + sin(current_time * pulse_speed) * pulse_amount;
    tracker_height *= height_scale;
    
    // Adjust Y position to keep the bar centered vertically
    tracker_y -= (tracker_height - original_height) / 2;
}

// Draw background and border of progress bar
//draw_set_color(c_black);
//draw_set_alpha(0.7);
//draw_roundrect(
    //tracker_x - border_thickness, 
    //tracker_y - border_thickness, 
    //tracker_x + tracker_width + border_thickness, 
    //tracker_y + tracker_height + border_thickness, 
    //false
//);
//draw_set_alpha(1.0);

// Draw outline of progress bar
//draw_set_color(c_white);
//draw_roundrect(
    //tracker_x - border_thickness, 
    //tracker_y - border_thickness, 
    //tracker_x + tracker_width + border_thickness, 
    //tracker_y + tracker_height + border_thickness, 
    //true
//);

// Draw progress bar background
//draw_set_color(c_dkgray);
//draw_rectangle(tracker_x, tracker_y, tracker_x + tracker_width, tracker_y + tracker_height, false);

// Choose progress bar color (subtle flash if in final 10%)
//var bar_color;
//if (in_final_stretch) {
    //// Create subtle flashing effect by oscillating between two colors
    //var flash_speed = 0.05; // Slower flash
    //var flash_intensity = 0.2 + sin(current_time * flash_speed) * 0.15; // Very subtle, oscillates between 0.05 and 0.35
    //
    //// Blend between lime and yellow for the flash effect - more lime than yellow
    //bar_color = merge_color(c_lime, c_yellow, flash_intensity);
//} else {
    //bar_color = c_lime;
//}

// Draw progress bar fill
//draw_set_color(bar_color);
//draw_rectangle(
    //tracker_x, 
    //tracker_y, 
    //tracker_x + tracker_width * progress_percentage, 
    //tracker_y + tracker_height, 
    //false
//);

// Add gradient effect to progress bar
//var grad_steps = 10;
//for (var i = 0; i < grad_steps; i++) {
    //var alpha = 0.1 + (i / grad_steps) * 0.2;
    //draw_set_alpha(alpha);
    //draw_line(
        //tracker_x + tracker_width * progress_percentage - i, 
        //tracker_y, 
        //tracker_x + tracker_width * progress_percentage - i, 
        //tracker_y + tracker_height
    //);
//}
draw_set_alpha(1.0);

// Add markers for progress bar start and destination
// Start marker
//draw_set_color(c_white);
//draw_circle(tracker_x, tracker_y + tracker_height/2, 5, false);
//
//// End marker
//draw_set_color(c_yellow);
//draw_circle(tracker_x + tracker_width, tracker_y + tracker_height/2, 5, false);
//
//// Current position marker
//var current_x = tracker_x + tracker_width * progress_percentage;
//
//// Make the position marker flash subtly in the final 10%
//if (in_final_stretch) {
    //var triangle_color = merge_color(c_white, c_yellow, flash_intensity * 0.5); // Very subtle
    //draw_set_color(triangle_color);
//} else {
    //draw_set_color(c_white);
//}

// Draw triangle pointer above the bar
//draw_triangle(
    //current_x, tracker_y - 10,
    //current_x - 6, tracker_y - 2,
    //current_x + 6, tracker_y - 2,
    //false
//);

// Draw time information
//draw_set_font(fnt_basic); // Replace with your font
//draw_set_halign(fa_center);
//draw_set_valign(fa_top);

// Calculate remaining time
//var distance_to_go = point_distance(current_run.overworld_x, current_run.overworld_y, current_run.target_x, current_run.target_y);
//var overspeed = current_run.travel_speed;
//var time_left = distance_to_go / overspeed;
//var total_time = total_distance / overspeed;

// Format the time values (convert to minutes:seconds format)
//var time_left_minutes = floor(time_left / 60);
//var time_left_seconds = floor(time_left mod 60);
//var total_time_minutes = floor(total_time / 60);
//var total_time_seconds = floor(total_time mod 60);
//
//var time_text = "";
// Format time with leading zeros for seconds
//if (time_left_seconds < 10) {
    //time_text = string(time_left_minutes) + ":0" + string(time_left_seconds);
//} else {
    //time_text = string(time_left_minutes) + ":" + string(time_left_seconds);
//}
//
//time_text += " / ";

//if (total_time_seconds < 10) {
    //time_text += string(total_time_minutes) + ":0" + string(total_time_seconds);
//} else {
    //time_text += string(total_time_minutes) + ":" + string(total_time_seconds);
//}

// Draw time text with subtle color change
//draw_set_color(c_white);
//draw_text(tracker_x + tracker_width/2, tracker_y - 25, time_text);

// Add distance information
//var distance_text = string_format(distance_traveled, 0, 0) + " / " + string_format(total_distance, 0, 0) + " units";
//draw_text(tracker_x + tracker_width/2, tracker_y + tracker_height + 10, distance_text);

// Reset drawing settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1.0);
}