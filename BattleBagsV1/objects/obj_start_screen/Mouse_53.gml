/// @description
// Mouse Click Event
//if (mouse_check_button_pressed(mb_left)) {
for (var i = 0; i < array_length(buttons); i++) {
    var btn = buttons[i];
    var bx = btn.x;
    var by = button_y;
    
    if (mouse_x > bx && mouse_x < bx + button_width && mouse_y > by && mouse_y < by + button_height) {
        if (btn.action == "deploy") {
            room_goto(rm_gameRoom);
        }
    }
    
        if (mouse_x > bx && mouse_x < bx + button_width && mouse_y > by && mouse_y < by + button_height) {
        if (btn.action == "shop") {
            room_goto(rm_intown_shop);
        }
    }
}
//}
