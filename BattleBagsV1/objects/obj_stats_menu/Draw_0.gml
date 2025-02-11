/// @description Draw Player Stats.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(fnt_basic);
draw_set_color(c_white);

draw_text(50, 50, "Player Stats:");
draw_text(50, 100, "Highest Combo: " + string(manager.player_stats.highest_combo));
draw_text(50, 140, "Enemies Defeated: " + string(manager.player_stats.enemies_defeated));
draw_text(50, 180, "Blocks Destroyed: " + string(manager.player_stats.blocks_destroyed));
draw_text(50, 220, "Longest Run: " + string(manager.player_stats.longest_run));
draw_text(50, 300, "Press ENTER/LEFT MOUSE to return.");

