function draw_sprite_oilpaint(sprite, img, _x, _y) {
    shader_set(shd_oilpaint);
    
    var radius = 1;
    var u_radius = shader_get_uniform(shd_oilpaint, "uni_Radius");
    var u_screen_size = shader_get_uniform(shd_oilpaint, "uni_ScreenSize");

    if (u_radius != -1) shader_set_uniform_i(u_radius, radius);
    if (u_screen_size != -1) shader_set_uniform_f(u_screen_size, sprite_get_width(sprite), sprite_get_height(sprite));
    
    texture_set_stage(0, sprite_get_texture(sprite, img));  // Ensure correct texture is used
    draw_sprite(sprite, img, _x, _y);
    
    shader_reset();
}

