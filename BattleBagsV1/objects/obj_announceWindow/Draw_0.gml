draw_self();
draw_set_font(fnt_basic);
draw_text_transformed(self.x -420, self.y -220, Message, 2, 2, 0);
draw_sprite_part_ext(Announcer, -1, 9, 22, 50, 50, self.x +200, self.y -150, 5, 7, c_white, 1);