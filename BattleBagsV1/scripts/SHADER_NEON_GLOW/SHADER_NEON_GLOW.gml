function SHADER_neon_glow(x_offset = 0, y_offset = 256) constructor {
    surface_base = surface_create(surface_get_width(application_surface), surface_get_height(application_surface) + y_offset);
    surface_pass = surface_create(surface_get_width(application_surface), surface_get_height(application_surface) + y_offset);
    
    u_outer_intesity          = 1.6;
    u_inner_intesity          = 2.125;
    u_inner_length_multiplier = 12;
    
    u_vector = shader_get_uniform(shd_blur_horizontal, "u_vector");
    u_texel  = shader_get_uniform(shd_blur_horizontal, "u_texel");
    
    
    
    static update_stats = function(inc = 0.01)
    {  
        var outer_mod = (keyboard_check(ord("W")) - keyboard_check(ord("Q"))) * inc;
        var inner_mod = (keyboard_check(ord("S")) - keyboard_check(ord("A"))) * inc;
        var i_len_mod = (keyboard_check(ord("C")) - keyboard_check(ord("X"))) * inc;
        
        
        u_outer_intesity          = max(0, u_outer_intesity + (outer_mod));
        u_inner_intesity          = max(0, u_inner_intesity + (inner_mod));
        u_inner_length_multiplier = max(0, u_inner_length_multiplier + (i_len_mod));
    }
    
    ///@description Must be called before any drawing that requires the glow effect.
    static draw_start = function()
    {
        surface_set_target(surface_base);
                draw_clear(c_black);
    }
    
    ///@description Must be called immediately after the glowing sprites are drawn.
    static draw_end = function()
    {
        //----------------------------------------------------------------
        // DRAW GLOWING BLOCKS
        //----------------------------------------------------------------
        surface_reset_target();
        
        // Make it glow horizontally
        surface_set_target(surface_pass);
        draw_clear_alpha(c_black, 0);
        
        shader_set(shd_blur_horizontal);
        shader_set_uniform_f(shader_get_uniform(shd_blur_horizontal, "u_glowProperties"), u_outer_intesity, u_inner_intesity, u_inner_length_multiplier);
        shader_set_uniform_f(shader_get_uniform(shd_blur_horizontal, "u_time"), current_time);
        
        gpu_set_blendenable(false);
        draw_surface(surface_base, 0, 0);
        gpu_set_blendenable(true);
        
        shader_reset();
        surface_reset_target();
        
        //// Vertical pass + final adjustments, add on top
        gpu_set_blendmode(bm_add);
        
        shader_set(shd_blur_vertical);
        shader_set_uniform_f(shader_get_uniform(shd_blur_vertical, "u_glowProperties"), u_outer_intesity, u_inner_intesity, u_inner_length_multiplier);
        shader_set_uniform_f(shader_get_uniform(shd_blur_vertical, "u_time"), current_time);
        draw_surface(surface_pass, 0, 0);
        shader_reset();
        
        gpu_set_blendmode(bm_normal); 
    }

    
    
    
    static clean_up = function()
    {
        if (surface_exists(surface_base)) {
            surface_free(surface_base);
        }
        
        if (surface_exists(surface_pass)) {
            surface_free(surface_pass);
        }
    }
}