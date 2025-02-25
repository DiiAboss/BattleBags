function draw_gui_neon_shader_stats(_self, _x = room_width/2, _y = room_height/2+100)
{
    var outer_intensity = _self.uOuterIntensity;
    var inner_intensity = _self.uInnerIntensity;
    var inner_multiplier = _self.uInnerLengthMultiplier;
    var stat_font = _self.stats_font;
    var default_font = _self.default_font;
    
    draw_set_font(stat_font);
    draw_set_color(c_lime);
    //draw_text(_x, _y, "FPS: " + string(fps_real) +
                    //"\nGlow intensity (Q/W): " + string(outer_intensity) +
                    //"\nInner glow intensity (A/S): " + string(inner_intensity) + 
                    //"\nInner glow falloff (X/C): " + string(inner_multiplier));
    draw_text_transformed(_x, _y, "FPS: " + string(fps_real) +
                        "\nGlow intensity (Q/W): " + string(outer_intensity) +
                        "\nInner glow intensity (A/S): " + string(inner_intensity) + 
                        "\nInner glow falloff (X/C): " + string(inner_multiplier), 2, 2, 0);
    draw_set_color(c_white);  
    draw_set_font(default_font);
}



function draw_text_heading_font(_x, _y, text, size = 1, c1 = c_white, c2 = c_white, c3 = c_white, c4 = c_white, alpha = 1, h_align = fa_center, v_align = fa_middle)
{
    
    var heading_fnt = fnt_heading1;
    var default_font = fnt_basic;
    
    draw_set_halign(h_align);
    draw_set_valign(v_align);
    draw_set_alpha(alpha);
    draw_set_font(heading_fnt); // ✅ Use the specified font 
    draw_text_transformed_color(
    _x, 
    _y, 
    text, 
    size, 
    size, 
    0, 
    c1, c2, c3, c4, alpha);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_font(default_font);
    
}


function draw_text_text_font(_x, _y, text)
{
    var default_fnt = fnt_basic;
    
    draw_set_font(fnt_textFont);
    draw_text(_x, _y, text);
    draw_set_font(fnt_basic);
    
}
