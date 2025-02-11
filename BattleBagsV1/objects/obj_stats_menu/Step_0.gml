/// @description Handle returning to the menu.
if (keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)) {
    room_goto(rm_main_menu);
}

