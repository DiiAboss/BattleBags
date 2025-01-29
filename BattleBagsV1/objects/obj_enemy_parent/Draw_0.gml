/// @description Insert description here
// You can write your code in this editor
draw_self();

if (damage_timer > 0)
{
	draw_text(x-64, y-128, string(total_damage));
}

draw_text(x-64, y-96, string(hp) + " / 999999");