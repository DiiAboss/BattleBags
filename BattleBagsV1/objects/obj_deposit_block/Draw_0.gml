draw_sprite_ext(sprite, img, x, y, 0.75, 0.75, rotation, c_white, 1);



// Draw debug info
if (keyboard_check(vk_tab)) {
    draw_set_color(c_white);
    draw_text(x - 40, y + 20, state);
    draw_text(x - 40, y + 35, "Type: " + string(current_block_type));
}