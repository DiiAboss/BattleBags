/// @description
/// 


var input = obj_game_manager.input;
input.Update(self, mouse_x, mouse_y);

if (input.Back) || input.Escape || input.AltPress
{
    if (current_menu == "main")
    {
        room_goto(rm_pre_game_screen);
    }
    else {
        current_menu = "main";
    }
}