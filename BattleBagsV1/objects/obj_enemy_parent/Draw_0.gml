/// @description Insert description here
// You can write your code in this editor
draw_self();

if (damage_timer > 0)
{
	draw_text(x-64, y-144, string(total_damage));
}

draw_text(x-64, y-128, string(hp) + " / " + string(max_hp));
draw_text(x-64, y-96, string(attack_timer) + " / " + string(max_attack_timer));
draw_text(x-64, y-160, "Total_Attacks: " + string(total_attacks));
draw_text(x-64, y-180, "Attacks_Until_Special: " + string(total_attacks % attacks_until_special_attack));
draw_text(x-64, y-200, "Attacks_TIMER_INC: " + string(global.enemy_timer_game_speed * (global.gameSpeed / obj_game_control.game_speed_default)));
