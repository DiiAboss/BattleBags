/// @description Handle returning to the menu.
var input = obj_game_manager.input;

input.Update(self);


if (input.ActionPress || input.Enter) {
    room_goto(rm_main_menu);
}

