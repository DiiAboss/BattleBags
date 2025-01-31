/// @description Insert description here
// You can write your code in this editor
if place_meeting(x, y, obj_player_attack)
{
	var incoming = instance_nearest(x, y, obj_player_attack);
	
	hp -= incoming.damage;
	
	
	damage_timer = max_damage_timer;
	total_damage += incoming.damage;
	damage_alpha = 1;
	
	with (incoming)
	{
		instance_destroy();
	}
}

if (damage_timer > 0)
{
	damage_timer -= 1;
	
	if (damage_timer < 10)
	{
		damage_alpha -= 0.1;
	}
}
else
{
	damage_timer = 0;
	damage_alpha = 0;
}

// ----------------------------------
// ✅ ENEMY ATTACK SYSTEM
// ----------------------------------
if (attack_timer >= max_attack_timer) {
	total_attacks += 1;
	if (total_attacks % attacks_until_special_attack == 0)
	{
		toss_down_shape(obj_game_control, "triangle_down_3x3", true);
	}
	else
	{
		enemy_attack_basic(self, obj_game_control);
	}
		
	
	
	attack_timer = 0;
}
else
{
	attack_timer_increase_mod = global.enemy_timer_game_speed / obj_game_control.game_speed_default;
	attack_timer += attack_timer_increase_mod;
}


// ✅ Check Death
if (hp <= 0) {
	enemy_defeated(self, obj_game_control);
}


function enemy_attack_basic(_self, game_control_object) {
    // 🔥 Generate a dynamic attack pattern based on `attack` value
    var attack_pattern = generate_attack_shape(_self.attack);

    // 🔥 Spawn attack blocks
    toss_down_shape(game_control_object, attack_pattern, true);
}

function generate_attack_shape(_attack) {
    var max_width = obj_game_control.width; // 🔥 Maximum width
    var max_height = 4;                     // 🔥 Maximum height (prevents game over)

    var shape_width = irandom_range(1, min(_attack, max_width)); 
    var shape_height = irandom_range(1, min(_attack div max_width + 1, max_height)); 

    // 🔥 Restrict the 4th row from forming until previous rows are full
    if (_attack >= (max_width * 3) && shape_height < 4) {
        shape_height = 3; 
    }

    var attack_template = array_create(shape_height);
    
    var remaining_blocks = _attack;
    
    for (var _y = 0; _y < shape_height; _y++) {
        attack_template[_y] = array_create(shape_width, BLOCK.NONE); // Initialize row
        
        for (var _x = 0; _x < shape_width; _x++) {
            if (remaining_blocks > 0) {
                attack_template[_y][_x] = BLOCK.RANDOM;
                remaining_blocks--;
            }
        }
        
        // 🔥 Add L-Shape or gap randomness
        if (remaining_blocks > 0 && irandom(3) == 0) {
            attack_template[_y][irandom(shape_width - 1)] = BLOCK.NONE;
            remaining_blocks++;
        }
    }
    
    // 🔥 Assign a unique name
    var attack_name = "dynamic_" + string(_attack) + "_" + string(irandom(9999));
    
    // 🔥 Store in global shape templates
    ds_map_add(global.shape_templates, attack_name, attack_template);
    
    return attack_name;
}


function enemy_defeated(_self, game_control_object) {
	// ✅ Grant Rewards
	global.gold	+= gold_reward;
	game_control_object.experience_points += exp_reward;

	// ✅ Increase enemy difficulty over time
	//global.enemies_defeated++;

	// ✅ Destroy enemy
	instance_destroy();
}