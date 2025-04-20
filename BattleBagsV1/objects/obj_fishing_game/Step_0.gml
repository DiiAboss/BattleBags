// In Step event:
if (keyboard_check_pressed(vk_space)) {
    if (fishing_game.phase == PHASE_IDLE) {
        fishing_game.StartFishing();
    } else if (fishing_game.phase == PHASE_RESULTS) {
        fishing_game.Initialize();
        fishing_game.StartFishing();
    }
}

if (keyboard_check(vk_left)) {
    fishing_game.MoveHook(-1 * delta_time / 1000000);
}

if (keyboard_check(vk_right)) {
    fishing_game.MoveHook(1 * delta_time / 1000000);
}

fishing_game.Update(delta_time);