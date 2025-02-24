function draw_text_stats(_self, x_start, y_start, enabled = false)
{
    if (!enabled) return;
        
    // Optional: Draw combo count
    draw_text(x_start, y_start + 40, "TIME: " + string(self.draw_time));
    draw_text(x_start, y_start + 60, "SPEED: " + string(self.game_speed_default));
    draw_text(x_start, y_start + 80, "alpha: " + string(self.darken_alpha));
    draw_text(x_start, y_start + 100, "LEVEL: " + string(self.level));
    draw_text(x_start, y_start + 120, "Combo: " + string(self.combo));
    draw_text(x_start, y_start + 140, "cTimer: " + string(self.combo_timer));
    
}
