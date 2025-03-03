/// @description Handles enemy damage when hit by player attacks

function create_enemy(start_x, start_y)
{
    var max_health = 100;
    var level = 1;
    
    var enemy_struct =
    {
        enemy_name:         "TEST_DUMMY_000",
        enemy_description:  "Used in testing, has all attacks equipped by default",
        level: level,
        hp:     max_health,
        max_hp: max_health,
        basic_attacks:   undefined,
        special_attacks: undefined,
        my_sprite:       spr_test_dummy,
        my_img:       0,
        attack_timer: 0,
        max_attack_timer: 0,
        exp_drop: 0,
        gold_drop: 0,
        is_boss: false,
        click_shield: 0,
        click_shield_spawn: 0,
        click_shield_max_spawn: 10,
        my_color: c_white,
        targetted: false,
    }
    
    return instance_create_depth(start_x, start_y, -1, obj_enemy_basic_parent, enemy_struct);
}


function init_enemy(enemy_control, start_x, start_y)
{
    var enemy = -1;
    
    enemy = create_enemy(start_x, start_y);
    enemy.basic_attacks = ds_list_create();
    enemy.special_attacks = ds_list_create();
    
    return enemy;
}


function assign_attack_to_enemy(enemy, attack, special = false)
{
    if (special == false)
    {
        ds_list_add(enemy.basic_attacks, attack);
    }
    else {
        ds_list_add(enemy.special_attacks, attack)
    }
}

function destroy_enemy(enemy)
{
    with (enemy)
    {
        ds_list_destroy(basic_attacks);
        ds_list_destroy(special_attacks);
        instance_destroy();        
    }
}

function enemy_apply_damage(enemy)
{
    if (place_meeting(enemy.x, enemy.y, obj_player_attack))
    {
        var incoming = instance_place(enemy.x, enemy.y, obj_player_attack);
        var incoming_damage = incoming.damage;
        
        
        if (enemy.shield_amount > 0)
        {
            enemy.shield_amount -= 1;
        }
        else {
            enemy.hp -= incoming_damage;
            enemy.damage_timer = enemy.max_damage_timer;
            enemy.total_damage += incoming_damage;
            enemy.damage_alpha = 1;
        }
        
        with (incoming) instance_destroy();
    }
}









function handle_damage(_self) {
    if (place_meeting(_self.x, _self.y, obj_player_attack)) {
        var incoming = instance_nearest(_self.x, _self.y, obj_player_attack);

        if (_self.shield_amount > 0)
        {
            shield_amount --;
        }
        else {
            _self.hp -= incoming.damage;
            _self.damage_timer = _self.max_damage_timer;
            _self.total_damage += incoming.damage;
            _self.damage_alpha = 1;
        }

        with (incoming) instance_destroy();
    }
}



/// @description Adjusts enemy attack power based on game speed
function adjust_attack_power(_self) {
    _self.attack_power = _self.default_attack_power + round(
        obj_game_control.game_speed_default - obj_game_control.game_speed_start
    );
}



/// @description Handles the damage fading effect
function update_damage_fade(_self) {
    if (_self.damage_timer > 0) {
        _self.damage_timer -= 1;
        if (_self.damage_timer < 10) {
            _self.damage_alpha -= 0.1;
        }
    } else {
        _self.damage_timer = 0;
        _self.damage_alpha = 0;
    }
}

/// @description Manages the attack timer and selects the next attack
function update_attack_timer(_self) {
    if (_self.attack_timer >= _self.max_attack_timer) {
        _self.total_attacks += 1;
        _self.attack_timer = 0; 
        //select_enemy_attack(_self); // ✅ Calls attack selection (can be overridden)
    }
    _self.attack_timer += global.enemy_timer_game_speed;
}

/// @description Manages the attack queue system
function manage_attack_queue(_self) {
    if (_self.enemy_attack_ready && obj_game_control.combo == 0) {
        _self.attack_queue_active = true;
    }

    if (_self.attack_queue_active) {
        process_attack_queue(_self);
    }
}

/// @description Handles enemy defeat logic
function check_if_enemy_defeated(_self) {
    if (_self.hp <= 0) {
        enemy_defeated(_self, obj_game_control);
    }
}





/// @function initialize_attack_previews
/// @description Pre-generates visual previews for all attack types
function initialize_attack_previews() {
    // Cache the special attack icons
    ds_map_add(attack_preview_cache, "FREEZE", { 
        sprite: spr_gameOver, 
        attack_type: ENEMY_ATTACK_TYPE.FREEZE 
    });
    
    ds_map_add(attack_preview_cache, "SLIME", { 
        sprite: spr_gameOver, 
        attack_type: ENEMY_ATTACK_TYPE.SLIME 
    });
    
    ds_map_add(attack_preview_cache, "BLOCK", { 
        sprite: spr_gameOver, 
        attack_type: ENEMY_ATTACK_TYPE.BLOCK 
    });
    
    // For shape-based attacks, we'll generate previews from templates
    var shape_names = ds_map_keys_to_array(global.shape_templates);
    for (var i = 0; i < array_length(shape_names); i++) {
        var shape_name = shape_names[i];
        // Skip special attacks we've already handled
        if (shape_name != "FREEZE" && shape_name != "SLIME" && shape_name != "BLOCK") {
            ds_map_add(attack_preview_cache, shape_name, {
                shape_template: ds_map_find_value(global.shape_templates, shape_name),
                attack_type: ENEMY_ATTACK_TYPE.BASIC
            });
        }
    }
}

/// @function sync_with_global_queue
/// @description Ensures conveyor visually represents the global attack queue
function sync_with_global_queue() {
    // If global queue is empty but conveyor isn't, don't do anything
    if (ds_list_size(global.enemy_attack_queue) == 0 && ds_list_size(conveyor_attacks) > 0) {
        return;
    }
    
    // Add new attacks from global queue to conveyor
    var attacks_to_add = min(
        ds_list_size(global.enemy_attack_queue) - ds_list_size(conveyor_attacks),
        max_visible_attacks - ds_list_size(conveyor_attacks)
    );
    
    if (attacks_to_add > 0) {
        for (var i = 0; i < attacks_to_add; i++) {
            var queue_index = ds_list_size(conveyor_attacks);
            if (queue_index < ds_list_size(global.enemy_attack_queue)) {
                var attack_name = global.enemy_attack_queue[| queue_index];
                add_attack_to_conveyor(attack_name);
            }
        }
    }
}

/// @function add_attack_to_conveyor
/// @description Adds a new attack to the conveyor belt
/// @param {string} attack_name - The name of the attack to add
function add_attack_to_conveyor(attack_name) {
    // Create attack data structure
    var attack_data = {
        attack_name: attack_name,
        y_pos: conveyor_start_y,
        lane: irandom(lane_count - 1),  // Random lane placement
        preview_data: ds_map_find_value(attack_preview_cache, attack_name)
    };
    
    // Add to conveyor list
    ds_list_add(conveyor_attacks, attack_data);
    
    return attack_data;
}

/// @function draw_attack_on_conveyor
/// @description Draws an attack preview at the specified position
/// @param {real} x_pos - The x position to draw at
/// @param {real} y_pos - The y position to draw at
/// @param {struct} attack_data - The attack data structure
function draw_attack_on_conveyor(x_pos, y_pos, attack_data) {
    var preview = attack_data.preview_data;
       
     // Safety check - if preview is undefined, draw a placeholder and exit
    if (preview == undefined) {
        // Draw a fallback/placeholder
        draw_circle_color(x_pos, y_pos, 20, c_red, c_maroon, false);
        draw_text(x_pos - 8, y_pos - 4, "?");
        return;
    }
    // Background for the attack
    var bg_color;
    
    switch (preview.attack_type) {
        case ENEMY_ATTACK_TYPE.FREEZE:
            bg_color = c_aqua;
            draw_sprite(preview.sprite, 0, x_pos, y_pos);
            break;
            
        case ENEMY_ATTACK_TYPE.SLIME:
            bg_color = c_lime;
            draw_sprite(preview.sprite, 0, x_pos, y_pos);
            break;
            
        case ENEMY_ATTACK_TYPE.BLOCK:
            bg_color = c_orange;
            draw_sprite(preview.sprite, 0, x_pos, y_pos);
            break;
            
        case ENEMY_ATTACK_TYPE.SPECIAL:
            bg_color = c_purple;
            draw_shape_preview(x_pos, y_pos, preview.shape_template);
            break;
            
        default: // Basic attacks
            bg_color = c_gray;
            draw_shape_preview(x_pos, y_pos, preview.shape_template);
            break;
    }
    
    // Draw background glow based on attack type
    draw_set_alpha(0.3);
    draw_circle_color(x_pos, y_pos, 36, bg_color, c_black, false);
    draw_set_alpha(1.0);
}

/// @function draw_shape_preview
/// @description Draws a shape preview for block-based attacks
/// @param {real} x_pos - Center X position to draw at
/// @param {real} y_pos - Center Y position to draw at
/// @param {array} shape_template - The shape template array
function draw_shape_preview(x_pos, y_pos, shape_template) {
    if (!is_array(shape_template)) return;
    
    var rows = array_length(shape_template);
    var cols = (rows > 0) ? array_length(shape_template[0]) : 0;
    
    // Size for preview blocks - using your new sprite size
    var block_size = 16;
    
    // Calculate the total dimensions
    var total_width = cols * block_size;
    var total_height = rows * block_size;
    
    // Draw each block in the preview
    for (var row = 0; row < rows; row++) {
        for (var col = 0; col < cols; col++) {
            var block_type = shape_template[row][col];
            if (block_type != BLOCK.NONE) {
                var draw_x = x_pos - (total_width / 2) + (col * block_size) + (block_size / 2);
                var draw_y = y_pos - (total_height / 2) + (row * block_size) + (block_size / 2);
                
                // Map block type to the appropriate subimage of spr_preview_block
                var subimage = map_block_type_to_subimage(block_type);
                
                // Draw the preview block
                draw_sprite(spr_preview_block, subimage, draw_x, draw_y);
            }
        }
    }
    
    // Draw an outline around the entire shape
    draw_set_color(c_white);
    draw_rectangle(
        x_pos - (total_width / 2) - 1, 
        y_pos - (total_height / 2) - 1,
        x_pos + (total_width / 2), 
        y_pos + (total_height / 2),
        true
    );
}

//enum BLOCK {
    //RANDOM = -99,  GAME_OVER = -404, CURSE = -5, PUZZLE_1 = -4, MEGA = -3, WILD = -2, NONE = -1, RED = 0, YELLOW = 1, GREEN = 2, PINK = 3, PURPLE = 4,
    //LIGHTBLUE = 5, ORANGE = 6, BLUE = 7, GREY = 8, WHITE = 9, BLACK = 10
//}


/// @function map_block_type_to_subimage
/// @description Maps a block type to the corresponding subimage in spr_preview_block
/// @param {real} block_type - The block type constant
/// @returns {real} The subimage index to use
function map_block_type_to_subimage(block_type) {
    // This function maps your BLOCK enum values to sprite subimages
    // Adjust these mappings based on your specific sprites
    switch (block_type) {
        case BLOCK.RED:
            return 0;  // Regular block (first subimage)
        case BLOCK.YELLOW:
            return 1;  // Red block
        case BLOCK.GREEN:
            return 2;  // Red block
        case BLOCK.PINK:
            return 3;  // Red block
        case BLOCK.PURPLE:
            return 4;  // Red block
        case BLOCK.LIGHTBLUE:
            return 5;  // Green block
        case BLOCK.ORANGE:
            return 6;  // Blue block
        case BLOCK.BLUE:
            return 7;  // Yellow block
        case BLOCK.MEGA:
            return 8;  // Purple block
        case BLOCK.CURSE:
            return 9;  // Black block
        case BLOCK.RANDOM:
            return irandom(5);  // Random color (0-5)
        default:
            return 0;  // Default to regular block
    }
}

/// @function trigger_attack_execution
/// @description Executes an attack when it reaches the activation point
/// @param {string} attack_name - The name of the attack to execute
function trigger_attack_execution(attack_name) {
    // Only execute if it's still in the global queue
    var queue_pos = ds_list_find_index(global.enemy_attack_queue, attack_name);
    if (queue_pos != -1) {
        // Different execution based on attack type
        switch (attack_name) {
            case "FREEZE":
                with (obj_enemy_basic_parent) {
                    if (pending_attack == "") {
                        pending_attack = "FREEZE";
                        select_attack_targets(self, "FREEZE");
                        alarm[0] = 1;  // Execute immediately
                    }
                }
                break;
                
            case "SLIME":
                with (obj_enemy_basic_parent) {
                    if (pending_attack == "") {
                        pending_attack = "SLIME";
                        select_attack_targets(self, "SLIME");
                        alarm[0] = 1;  // Execute immediately
                    }
                }
                break;
                
            case "BLOCK":
                spawn_mega_block(obj_game_control, irandom_range(0, 5), 2, "block_1x3");
                break;
                
            default:
                // For normal shape attacks
                toss_down_shape(obj_game_control, attack_name, true);
                break;
        }
        
        // Remove from global queue
        ds_list_delete(global.enemy_attack_queue, queue_pos);
        
        // Create execution effect at the activation line
        //instance_create_layer(x, conveyor_activation_y, "Effects", obj_attack_effect);
    }
}