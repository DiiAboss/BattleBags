enum CURRENCY 
{
    NONE,
    ALL,
    JUNK,
    COMBITS,
    COMBYTES,
    COMBONES,
    COMBINS,
    COMBAXS,
    COMBILLIONS,
}

enum POLARITY
{
    NEGATIVE,
    POSITIVE,
    NEUTRAL   
}

enum VALUE
{
    TRUE = 999,
    FALSE = -999,
}


global.Manufacturers = {
    recycler: ["Nullport Systems", "Blocksmith Inc", "Oshki-Tech"],
    grid:     ["GridShift Labs", "Axiom Movers"],
    drones:   ["SkyBits", "HexaCore", "Hoverbyte"],
    alt:      ["Combodrone Co.", "MechaNova", "SynthIndustries"]
};


global.Upgrades = 
{
    recycler: 
    {
        name: "Recycler",
        
        cooldown:
        {
            name: "Cooldown",
            desc: "Recycler Cooldown Rate",
            increase:
            { 
                name: "Increase",
                desc: "Increase the speed of the recycler output",
                value: 0.01,
                pol: POLARITY.POSITIVE,
                rarity: 10,
                target_var: "obj_recycler.max_cooldown",
                requires: "",
            },
            
            decrease:
            {
                name: "Decrease",
                desc: "Reduce the speed of the recycler output",
                value: -0.01,
                pol: POLARITY.NEGATIVE,
                rarity: 10,
                target_var: "obj_recycler.max_cooldown",
                requires: "",
            }
        },

        rotation:
        {
            name: "Rotation",
            desc: "Recycler Rotation",

            activate:
            {
                name: "Activate",
                desc: "Recycler Rotation",
                on:
                { 
                    name: "On",
                    desc: "Activate Recycler Rotation",
                    value: VALUE.TRUE,
                    pol: POLARITY.NEUTRAL,
                    rarity: 20,
                    target_var: "obj_recycler.max_rotation",
                    requires: "",
                },
                
                off:
                {
                    name: "Off",
                    desc: "Deactivate Recycler Rotation",
                    value: VALUE.FALSE,
                    pol: POLARITY.NEUTRAL,
                    rarity: 20,
                    target_var: "obj_recycler.max_rotation",
                    requires: "",
                }
            },
    

            increase:
            { 
                name: "Increase",
                desc: "Increase the Recycler Rotation",
                value: 0.01,
                pol: POLARITY.POSITIVE,
                rarity: 20,
                target_var: "obj_recycler.max_rotation",
                requires: "",
            },
            
            decrease:
            {
                name: "Decrease",
                desc: "Reduce the Recycler Rotation",
                value: -0.01,
                pol: POLARITY.NEGATIVE,
                rarity: 20,
                target_var: "obj_recycler.max_rotation",
                requires: "",
            }
        },


        bad_block:
        {
            name: "Bad Block",

            disable:
            {
                name: "Disable",
                desc: "Disable Bad Blocks",
                on:
                { 
                    name: "On",
                    desc: "Activate Bad Block",
                    value: VALUE.TRUE,
                    pol: POLARITY.NEUTRAL,
                    rarity: 20,
                    target_var: "obj_recycler.max_rotation",
                    requires: "",
                },
                
                off:
                {
                    name: "Off",
                    desc: "Deactivate Recycler Rotation",
                    value: VALUE.FALSE,
                    pol: POLARITY.NEUTRAL,
                    rarity: 20,
                    target_var: "obj_recycler.max_rotation",
                    requires: "",
                },

                max_timer:
                {
                    name: "Timer",
                    desc: "Recycler Bad Block Disable Timer",
                    increase:
                   { 
                       name: "Increase",
                       desc: "Increase the Recycler Bad Block Disable Timer",
                       value: 0.01,
                       pol: POLARITY.POSITIVE,
                       rarity: 20,
                       target_var: "obj_recycler.max_rotation",
                       requires: "",
                   },
                   
                   decrease:
                   {
                       name: "Decrease",
                       desc: "Reduce the Recycler Bad Block Disable Timer",
                       value: -0.01,
                       pol: POLARITY.NEGATIVE,
                       rarity: 20,
                       target_var: "obj_recycler.max_rotation",
                       requires: "",
                   }
                },

                cooldown:
                {
                    name: "Cooldown",
                    desc: "Recycler Cooldown Timer",
                    increase:
                    { 
                        name: "Increase",
                        desc: "Increase the Recycler Cooldown Timer",
                        value: 0.01,
                        pol: POLARITY.NEGATIVE,
                        rarity: 20,
                        target_var: "obj_recycler.max_rotation",
                        requires: "",
                    },
                    
                    decrease:
                    {
                        name: "Decrease",
                        desc: "Reduce the Recycler Cooldown Timer",
                        value: -0.01,
                        pol: POLARITY.POSITIVE,
                        rarity: 20,
                        target_var: "obj_recycler.max_rotation",
                        requires: "",
                    }
                },
            }, 


            chance:
            {
                name: "Chance",
                desc: "Recycler Bad Block Spawn Rate",
                increase: 
                {
                    name: "Increase",
                    desc: "Increase the chance of a bad block spawning",
                    value: 0.05,
                    pol: POLARITY.NEGATIVE,
                    rarity: 15
                },

                decrease:
                {
                    name: "Decrease",
                    desc: "Reduce the chance of a bad block spawning",
                    value: 0.05,
                    pol: POLARITY.POSITIVE,
                    rarity: 15
                }
            }
        }, 

        copper_block:
        {
            name: "Copper Block",
            chance:
            {
                name: "Chance",
                increase:
                {
                    name: "Increase",
                    desc: "Increase chance to spawn copper blocks",
                    value: 0.05,
                    pol: POLARITY.POSITIVE,
                    rarity: 10
                },
                decrease:
                {
                    name: "Decrease",
                    desc: "Decrease chance to spawn copper blocks",
                    value: -0.05,
                    pol: POLARITY.NEGATIVE,
                    rarity: 5
                },
            },
        },

        silver_block:
        {
            name: "Silver Block",
            chance:
            {
                name: "Chance",
                increase:
                {
                    name: "Increase",
                    desc: "Increase chance to spawn silver blocks",
                    value: 0.05,
                    pol: POLARITY.POSITIVE,
                    rarity: 15
                },
                decrease:
                {
                    name: "Decrease",
                    desc: "Decrease chance to spawn silver blocks",
                    value: -0.05,
                    pol: POLARITY.NEGATIVE,
                    rarity: 15
                }
            }
        },

        gold_block:
        {
            name: "Gold Block",
            chance:
            {
                name: "Chance",
                increase:
                {
                    name: "Increase",
                    desc: "Increase chance to spawn gold blocks",
                    value: 0.05,
                    pol: POLARITY.POSITIVE,
                    rarity: 20
                },
                decrease:
                {
                    name: "Decrease",
                    desc: "Decrease chance to spawn gold blocks",
                    value: -0.05,
                    pol: POLARITY.NEGATIVE,
                    rarity: 15
                },
                
            },
        },

        block_spawn:
        {
            name: "Block Spawn",
            chance:
            {
                increase:
                {
                    name: "Increase",
                    desc: "Increase the chance of a block spawning from the recycler",
                    value: 0.05,
                    pol: POLARITY.POSITIVE,
                    rarity: 10
                },
                decrease:
                {
                    name: "Decrease",
                    desc: "Reduce the chance of a block spawning from the recycler",
                    value: -0.05,
                    pol: POLARITY.NEGATIVE,
                    rarity: 5
                },
            },
        },
        
        powerup:
        {
            name: "Powerup",
            spawn:
            {
                name: "Spawn",
                rate: 
                {
                    name: "Rate",
                    increase:
                   {
                       name: "Increase",
                       desc: "Increase the chance of a block spawning from the recycler",
                       value: 0.05,
                       pol: POLARITY.POSITIVE,
                       rarity: 10
                   },
                   decrease:
                   {
                       name: "Decrease",
                       desc: "Reduce the chance of a block spawning from the recycler",
                       value: -0.05,
                       pol: POLARITY.POSITIVE,
                       rarity: 10
                   },
                },
            },
        },

    },

    grid:
    {
        name: "Grid",
        shift:
        {
            name: "Shift",
            rate:
            {
                name: "Rate",
                decrease: 
                { 
                    name: "Decrease", 
                    desc: "Slow down the grid shift rate", 
                    value: -0.05, 
                    rarity: 10, 
                    pol: POLARITY.POSITIVE 
                },
                increase: 
                { 
                    name: "Increase", 
                    desc: "Speed up the grid shift rate", 
                    value: 0.05, 
                    rarity: 10, 
                    pol: POLARITY.NEGATIVE
                },
            },
        },
    },

    block:
    {
        match_bonus:
        {
            name: "Match Bonus",
            desc: "Increase the points gained from matching blocks",
            value: 0.10,
            pol: POLARITY.POSITIVE,
            rarity: 15
        },
        
    },

    drones:
    {
        name: "Drones",
        speed:
        {
            name: "Movement Speed",
            increase: 
            { 
              name: "Increase",
              desc: "Increase drone movement speed",
              value: 0.05,
              pol: POLARITY.POSITIVE,
              rarity: 10,
            },
            decrease: 
            { 
              name: "Decrease",
              desc: "Decrease drone movement speed",
              value: -0.05,
              pol: POLARITY.POSITIVE,
              rarity: 10,
            },
        },

        carry_capacity:
        {
            name: "Carry Capacity",
            increase: 
            {
                name: "Increase",
              desc: "Increase Drone Carry Capacity",
              value: 1,
              pol: POLARITY.POSITIVE,
              rarity: 10,
              },
              decrease: 
              { 
              name: "Decrease",
              desc: "Decrease Drone Carry Capacity",
              value: -1,
              pol: POLARITY.NEGATIVE,
              rarity: 10,
              },
        },
    },

    drone_mods:
    {
        attack:
        {
            name: "Attack",
            desc: "Drones gain attack capability, damaging glitches",
            value: 1,
            pol: POLARITY.POSITIVE,
            rarity: 20
        },
        gather:
        {
            name: "Gather Efficiency",
            desc: "Drones gather blocks faster",
            value: 0.05,
            pol: POLARITY.POSITIVE,
            rarity: 15
        }
    },

    sorter:
    {
        powerup_sorting:
        {
            name: "Powerup Sorting",
            desc: "Sorters place powerup blocks strategically on the grid",
            value: 0.05,
            pol: POLARITY.POSITIVE,
            rarity: 15
        }
    },

    conveyor:
    {
        name: "Conveyor",
        speed:
        { 
            name: "Speed",
            increase: 
            {
                name: "Increase",
                desc: "Increase Conveyor Speed",
                value: 0.01,
                pol: POLARITY.POSITIVE,
                rarity: 10, 
            },
            decrease: 
            { 
                name: "Decrease",
                desc: "Decrease Conveyor Speed",
                value: -0.01,
                pol: POLARITY.NEGATIVE,
                rarity: 10,
            },
        },
    },

    powerup:
    {
        name: "Powerup",
        all_powerups:
        {
            name: "All",
            spawn_rate:
            {
                name: "Spawn",
                desc: "All Unlocked Powerups Spawn ",
                increase: 
                {
                    name: "Increase",
                    desc: "Increase All Unlocked Powerups Spawn Rate",
                    value: 0.01,
                    pol: POLARITY.POSITIVE,
                    rarity: 20,
                    target_var: "",
                },
                decrease: 
                {
                    name: "Decrease",
                    desc: "Decrease All Unlocked Powerups Spawn Rate",
                    value: -0.01,
                    pol: POLARITY.NEGATIVE,
                    rarity: 18,
                    target_var: "",
                },
            },
        },
        bow:
        { 
            name: "Bow",
            spawn_rate:
            {
               name: "Spawn Rate",
                increase: 
                {
                    name: "Increase",
                    desc: "Increase Bow Powerup Spawn Rate",
                    value: 0.01,
                    pol: POLARITY.POSITIVE,
                    rarity: 20,
                    target_var: "",
                },
                decrease: 
                {
                    name: "Decrease",
                    desc: "Decrease Bow Powerup Spawn Rate",
                    value: -0.01,
                    pol: POLARITY.NEGATIVE,
                    rarity: 18,
                    target_var: "",
                },
            },
            distance:
            {
            name: "Distance",
                increase: 
                {
                    name: "Increase",
                    desc: "Increase Bow Powerup Distance",
                    value: 0.01,
                    pol: POLARITY.POSITIVE,
                    rarity: 20,
                    target_var: "",
                },
                decrease: 
                {
                    name: "Decrease",
                    desc: "Decrease Bow Powerup Distance",
                    value: -0.01,
                    pol: POLARITY.NEGATIVE,
                    rarity: 18,
                    target_var: "",
                },
            },
        },
        bomb:
        { 
            name: "Bomb",
            spawn_rate:
            {
                name: "Spawn Chance",
                increase: 
                {
                    name: "Increase",
                    desc: "Increase Bomb Powerup Spawn Rate",
                    value: 0.01,
                    pol: POLARITY.POSITIVE,
                    rarity: 20,
                    target_var: "",
                },
                decrease: 
                {
                    name: "Decrease",
                    desc: "Decrease Bomb Powerup Spawn Rate",
                    value: -0.01,
                    pol: POLARITY.NEGATIVE,
                    rarity: 18,
                    target_var: "",
                },
            },
            size:
            {
                name: "Size",
                increase: 
                {
                    name: "Increase",
                    desc: "Increase Bomb Explosion Size",
                    value: 0.01,
                    pol: POLARITY.POSITIVE,
                    rarity: 20,
                    target_var: "",
                },
                decrease: 
                {
                    name: "Decrease",
                    desc: "Decrease Bomb Explosion Size",
                    value: -0.01,
                    pol: POLARITY.NEGATIVE,
                    rarity: 18,
                    target_var: "",
                },
            },
        },
    },

    skills:
    {
        name: "Skills",
        cooldown_reduction:
        {
            name: "Cooldown Reduction",
            increase: 
            {
                name: "Increase",
                desc: "Increase Cooldown Reduction Of All Active Skills",
                value: 0.01,
                pol: POLARITY.POSITIVE,
                rarity: 20,
                target_var: "",
            },
            decrease: 
            {
                name: "Decrease",
                desc: "Decrease Cooldown Reduction Of All Active Skills",
                value: -0.01,
                pol: POLARITY.NEGATIVE,
                rarity: 18,
                target_var: "",
            },
        },
    },

    combo:
    {
        copper_combo:
        {
            decrease:
            {
                name: "Copper Combo Decrease",
                desc: "Decrease combos needed for Copper Level",
                value: 1,
                pol: POLARITY.POSITIVE,
                rarity: 10
            },
            increase:
            {
                name: "Copper Combo Increase",
                desc: "Increase combos needed for Copper Level",
                value: 1,
                pol: POLARITY.NEGATIVE,
                rarity: 10
            }
        },
        silver_combo:
        {
            name: "Silver Combo",
            desc: "Combos grant higher chance of silver blocks",
            value: 1,
            pol: POLARITY.POSITIVE,
            rarity: 15
        },
        gold_combo:
        {
            name: "Gold Combo",
            desc: "Combos grant higher chance of gold blocks",
            value: 1,
            pol: POLARITY.POSITIVE,
            rarity: 20
        }
    }
}



//var price_1 = [price(CURRENCY.COMBITS, 99), price(CURRENCY.COMBYTES, 99)];
global.currency = array_create(CURRENCY.COMBILLIONS + 1, 0);

function shop() constructor 
{
    shop_items = [];
    
    for (var i = 0; i < 8; i++) {
        array_push(shop_items, create_random_shop_upgrade());
    }
    // Internal shop state
    hover_index = 0;
    selected_item = -1;
    scroll_offset = 0;
    target_scroll = 0;
    scroll_speed = 0.2;
    are_you_sure = false;
    input_delay = 30;
    input_delay_max = 30;
    dialogue_text = "Welcome! Browse my wares.";


    update = function() 
    {
        var input = obj_game_manager.input; // or however you handle input
    
        if (input.Escape || keyboard_check_pressed(ord("U")))
        {
            instance_destroy(); // Close shop
            obj_game_control.in_shop = false;
            return;
        }
    
        var max_index = array_length(shop_items) - 1;
    
        // Handle scroll input
        if (input.ScrollUp) hover_index = max(hover_index - 1, 0);
        if (input.ScrollDown) hover_index = min(hover_index + 1, max_index);
    
        // Smooth scrolling
        target_scroll = hover_index * 88;
        scroll_offset = lerp(scroll_offset, target_scroll, scroll_speed);
    
        // Hover highlighting
        for (var i = 0; i <= max_index; i++) {
            shop_items[i].hovered = (i == hover_index);
        }
    
        // Confirm selection
        if (input.ActionPress) {
            if (!are_you_sure) {
                are_you_sure = true;
                dialogue_text = "Are you sure you want to purchase " + shop_items[hover_index].name + "?";
            } else {
                are_you_sure = false;
                try_to_buy(shop_items[hover_index]);
            }
        }
    
        input_delay--;
    }
    
    draw = function()
    {
        var _x = 100;
        var y_start = 120;
        var item_h = 80;
        var pad = 8;
        var w = 600;

        draw_set_font(fnt_basic);
        draw_set_color(c_white);
        draw_set_halign(fa_left);

        var _y = y_start - scroll_offset;

        for (var i = 0; i < array_length(shop_items); i++) {
            var item = shop_items[i];
            var is_hovered = (i == hover_index);

            var bg_color = item.purchased ? c_dkgray : (is_hovered ? c_green : c_gray);
            draw_rectangle_color(_x, _y, x + w, _y + item_h, bg_color,bg_color,bg_color,bg_color, false);
            draw_text(_x + 16, _y + 8, item.name);
            draw_text(_x + 16, _y + 32, item.desc);
            draw_price_array(item.price, _x + 16, _y + 52);

            _y += item_h + pad;
        }

        // Dialogue box
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(room_width / 2, room_height - 100, dialogue_text);
    }
    

    
    try_to_buy = function(item) {
            if (!item.purchased && can_afford(item.price)) {
                pay_price(item.price);
                item.purchased = true;
                dialogue_text = "Purchased: " + item.name;
            } else if (item.purchased) {
                dialogue_text = "Already owned.";
            } else {
                dialogue_text = "Not enough resources.";
            }
        }
    
}


/// @desc shop_upgrade Constructor used to create shop upgrades
/// @param {string} _name Description
/// @param {string} _desc Description
/// @param {string} _type Description
/// @param {any} price_array Description
function shop_upgrade(_name, _desc, _type, price_array, _sprite, _img = 0, _level = 1) constructor
{
    name = _name;
    desc = _desc;
    price = price_array;
    sprite = _sprite;
    img = _img;
    type = _type;
    purchased = false;
    hovered = false;
    level = _level;
}

function price(type, amount)
{
    return [type, amount];
}

function create_random_shop_upgrade()
{
    
}

function draw_price_array(price_array, _x, _y)
{
    for (var i = 0; i < array_length(price_array); i++) {
        var p = price_array[i];
        var currency_type = p[0];
        var amount = p[1];

        var currency_name = string(currency_type); // For now, just show enum value
        draw_text(_x + i * 120, _y, currency_name + ": " + string(amount));
    }
}

//array_push(shop_items, new shop_upgrade("", "", "", price_1, spr_Oshki));
//function create_random_shop_upgrade() {
    //var name = "Random Upgrade";
    //var desc = "A random mysterious upgrade.";
    //var type = "upgrade";
    //var price_array = [
        //price(CURRENCY.COMBITS, irandom_range(50, 150)),
        //price(CURRENCY.COMBYTES, irandom_range(10, 50))
    //];
    //var sprite = spr_Oshki;
    //
    //return new shop_upgrade(name, desc, type, price_array, sprite);
//}


function can_afford(price_array) {
    for (var i = 0; i < array_length(price_array); i++) {
        var p = price_array[i];
        var type = p[0];
        var amount = p[1];
        if (global.currency[type] < amount) {
            return false;
        }
    }
    return true;
}

function pay_price(price_array) {
    for (var i = 0; i < array_length(price_array); i++) {
        var p = price_array[i];
        var type = p[0];
        var amount = p[1];
        global.currency[type] -= amount;
    }
}

function get_random_upgrade_path(_node, _path = "")
{
    var candidates = [];

    // Get struct keys (GameMaker doesn't have a built-in function for this,
    // so we need to manually define keys in an array when creating the structure,
    // OR we hardcode key access here)

    // Loop through keys in _node
    var keys = variable_struct_get_names(_node);

    for (var i = 0; i < array_length(keys); i++) {
        var key = keys[i];
        var value = _node[? key];

        if (is_struct(value) && variable_struct_exists(value, "Upgrades")) {
            var nested = get_random_upgrade_path(value.upgrades, _path + key + ".");
            if (nested != undefined) {
                array_push(candidates, nested);
            }
        } 
        else if (is_struct(value) && variable_struct_exists(value, "value")) {
            array_push(candidates, _path + key);
        }
    }

    if (array_length(candidates) > 0) {
        return candidates[irandom(array_length(candidates) - 1)];
    }
    
    return undefined;
}
function get_upgrade_by_path(path_string)
{
    var parts = string_split(path_string, ".");
    var current = shop_upgrades;

    for (var i = 0; i < array_length(parts); i++) {
        current = current[? parts[i]];
        if (current == undefined) return undefined;
        if (current[? "Upgrades"]) current = current[? "Upgrades"];
    }

    return current;
}

function Upgrade(_name, _description, _target, _target_variable, _value) constructor
{
    name = _name;
    description = _description;
    target = _target;
    target_variable = _target_variable;
    level = 1;
    value = _value;
    
    
    static Apply = function(_target = target, _target_variable = target_variable, _value = value)
    {
        if !(_target) return;
            
        if (!variable_instance_exists(_target, _target_variable)) return;
            
        var get = variable_instance_get(_target, _target_variable);
        variable_instance_set(_target, _target_variable, get + _value);
    }
}

function calculate_rarity(mod_list) {
    var total = 0;
    for (var i = 0; i < array_length(mod_list); i++) {
        var _mod = mod_list[i];
        var base = 10; // static weight for any modifier
        var impact = abs(_mod.value) * 100; // 5% = 5
        total += base + impact;
        if (_mod.type == "negative") total -= (base + impact); // subtract negatives
    }
    
    if (total < 15) return "Common";
    else if (total < 30) return "Uncommon";
    else if (total < 45) return "Rare";
    else if (total < 60) return "Epic";
    return "Legendary";
}

function array_random(array)
{
    var len = array_length(array) - 1;
    var rand = irandom(len);
    return (array[rand]);
}

// Global array to store paths during recursion
var _temp_paths = [];

// Recursive function to explore struct and find all paths
function explore_struct_recursive(_struct, _path_so_far) {
    if (variable_struct_exists(_struct, "value")) {
        // Found a leaf node, save it
        var _path_copy = [];
        array_copy(_path_copy, 0, _path_so_far, 0, array_length(_path_so_far));
        var _path_data = {
            path: _path_copy,
            data: _struct
        };
        array_push(_temp_paths, _path_data);
        return;
    }
    
    // Get all keys in this struct
    var _keys = variable_struct_get_names(_struct);
    
    // Explore each key
    for (var _i = 0; _i < array_length(_keys); _i++) {
        var _key = _keys[_i];
        
        // Skip metadata keys
        if (_key == "name" || _key == "desc" || _key == "pol" || 
            _key == "rarity" || _key == "target_var" || _key == "requires") {
            continue;
        }
        
        var _next_struct = variable_struct_get(_struct, _key);
        
        // Only process if it's a struct
        if (is_struct(_next_struct)) {
            // Add this key to the path
            var _new_path = [];
            array_copy(_new_path, 0, _path_so_far, 0, array_length(_path_so_far));
            array_push(_new_path, _key);
            
            // Explore deeper
            explore_struct_recursive(_next_struct, _new_path);
        }
    }
}

// Function to find all upgrade paths
function find_all_upgrade_paths() {
    // Clear the global paths array
    _temp_paths = [];
    
    // Start exploring from the root with empty path
    explore_struct_recursive(global.Upgrades, []);
    
    // Copy the results
    var _result = [];
    array_copy(_result, 0, _temp_paths, 0, array_length(_temp_paths));
    
    // Clear the global array
    _temp_paths = [];
    
    // Return the collected paths
    return _result;
}

// Generate a single upgrade
function generate_upgrade() {
    var _mod_list = [];
    var _total_rarity = 0;
    var _mod_attempts = irandom_range(1, 3); // Allow 1-3 mods per upgrade
    var _attempts = 100;
    
    // Find all possible upgrade paths
    var _all_paths = find_all_upgrade_paths();
    
    // If no paths found, return undefined
    if (array_length(_all_paths) == 0) {
        show_debug_message("No upgrade paths found!");
        return undefined;
    }
    
    // Try to find enough unique mods
    while (_mod_attempts > 0 && _attempts > 0) {
        _attempts--;
        
        // Pick a random upgrade path
        var _path_index = irandom(array_length(_all_paths) - 1);
        var _path_data = _all_paths[_path_index];
        var _path = _path_data.path;
        var _struct = _path_data.data;
        
        // Check if we already added this mod
        var _already_added = false;
        var _path_string = string_join(".", _path);
        
        for (var _j = 0; _j < array_length(_mod_list); _j++) {
            if (_mod_list[_j].path_string == _path_string) {
                _already_added = true;
                break;
            }
        }
        
        if (_already_added) continue;
        
        // Build the mod object
        var _system = _path[0];
        var _property = (array_length(_path) > 1) ? _path[1] : "General";
        var _modifier = (array_length(_path) > 2) ? _path[2] : "Default";
        var _submodifier = (array_length(_path) > 3) ? _path[3] : "";
        
        // Determine value type
        var _value_type = "numeric";
        if (_struct.value == VALUE.TRUE || _struct.value == VALUE.FALSE) {
            _value_type = "boolean";
        }
        
        var _mod = {
            system: _system,
            property: _property,
            modifier_key: _modifier,
            submodifier: _submodifier,
            name: _struct.name,
            desc: _struct.desc,
            value: _struct.value,
            value_type: _value_type,
            polarity: _struct.pol,
            rarity: _struct.rarity,
            path_string: _path_string,
            path: _path
        };
        
        // Add target_var if it exists
        if (variable_struct_exists(_struct, "target_var")) {
            _mod.target_var = _struct.target_var;
        }
        
        // Add requires if it exists
        if (variable_struct_exists(_struct, "requires")) {
            _mod.requires = _struct.requires;
        }
        
        // Add the mod to our list
        array_push(_mod_list, _mod);
        _total_rarity += _mod.rarity;
        _mod_attempts--;
    }
    
    // If we didn't find any mods, return undefined
    if (array_length(_mod_list) == 0) {
        show_debug_message("Upgrade generation failed after multiple attempts.");
        return undefined;
    }
    
    // Calculate rarity
    var _average_rarity = _total_rarity / array_length(_mod_list);
    var _upgrade_rarity = rarity_from_value(_average_rarity);
    var _mod_color = rarity_to_color(_upgrade_rarity);
    
    // Find manufacturer
    var _system_main = _mod_list[0].system;
    var _manufacturer_list = variable_struct_exists(global.Manufacturers, _system_main)
        ? variable_struct_get(global.Manufacturers, _system_main)
        : global.Manufacturers.alt;
    var _maker = array_random(_manufacturer_list);
    
    // Generate name
    var _full_name = _maker + "'s " + _mod_list[0].name;
    
    // Add property to the name
    if (_mod_list[0].property != "General") {
        _full_name += " " + string_upper(_mod_list[0].property);
    }
    
    // Add modifier for deeper paths
    if (_mod_list[0].modifier_key != "Default" && _mod_list[0].modifier_key != "increase" && 
        _mod_list[0].modifier_key != "decrease") {
        _full_name += " " + string_upper(_mod_list[0].modifier_key);
    }
    
    // Add submodifier for the deepest level
    if (_mod_list[0].submodifier != "") {
        _full_name += " " + string_upper(_mod_list[0].submodifier);
    }
    
    // Return the completed upgrade
    return {
        name: _full_name,
        mods: _mod_list,
        rarity: _upgrade_rarity,
        color: _mod_color,
        manufacturer: _maker,
        system: _system_main,
    };
}

// Debug function to test the upgrade generation
function generate_debug_upgrades() {
    // Find all possible upgrade paths
    var _all_paths = find_all_upgrade_paths();
    show_debug_message("Total possible upgrade paths: " + string(array_length(_all_paths)));
    
    // Print a few sample paths
    var _max_samples = min(5, array_length(_all_paths));
    for (var _i = 0; _i < _max_samples; _i++) {
        var _path = _all_paths[_i];
        show_debug_message("Path " + string(_i+1) + ": " + string_join(".", _path.path) + 
                        " → " + _path.data.desc);
    }
    
    // Generate and display some upgrades
    for (var _i = 0; _i < 10; _i++) {
        var _upg = generate_upgrade();
        if (_upg != undefined) {
            show_debug_message("\nUpgrade: " + _upg.name + " [" + _upg.rarity + "]");
            
            for (var _m = 0; _m < array_length(_upg.mods); _m++) {
                var _mod = _upg.mods[_m];
                
                // Get polarity text
                var _polarity_text = "";
                if (_mod.polarity == POLARITY.POSITIVE) {
                    _polarity_text = "Positive";
                } else if (_mod.polarity == POLARITY.NEGATIVE) {
                    _polarity_text = "Negative";
                } else {
                    _polarity_text = "Neutral";
                }
                
                // Format the effect text
                var _effect_text = "";
                if (_mod.value_type == "boolean") {
                    if (_mod.value == VALUE.TRUE) {
                        _effect_text = "Enable";
                    } else {
                        _effect_text = "Disable";
                    }
                } else {
                    // For numeric values
                    if (abs(_mod.value) < 1 && _mod.value != 0) {
                        _effect_text = _mod.desc + " by " + string(abs(_mod.value) * 100) + "%";
                    } else {
                        _effect_text = _mod.desc + " by " + string(_mod.value);
                    }
                }
                
                show_debug_message(" - Mod: " + _mod.name 
                    + ", Rarity: " + string(_mod.rarity) 
                    + ", Polarity: " + _polarity_text
                    + ", Effect: " + _effect_text
                    + ", Path: " + _mod.path_string);
            }
        } else {
            show_debug_message("Upgrade generation failed - struct not found or incomplete.");
        }
    }
}

//// Helper function to find all possible upgrade paths (for debugging)
//function find_all_upgrade_paths() {
    //var _all_paths = [];
    //
    //function explore_struct(_struct, _current_path) {
        //var _keys = variable_struct_get_names(_struct);
        //
        //for (var _i = 0; _i < array_length(_keys); _i++) {
            //var _key = _keys[_i];
            //
            //// Skip name and desc properties
            //if (_key == "name" || _key == "desc") continue;
            //
            //var _next_struct = variable_struct_get(_struct, _key);
            //var _new_path = [];
            //array_copy(_new_path, 0, _current_path, 0, array_length(_current_path));
            //array_push(_new_path, _key);
            //
            //if (variable_struct_exists(_next_struct, "value")) {
                //// Found a leaf node with a value
                //array_push(_all_paths, {
                    //path: _new_path,
                    //data: _next_struct
                //});
            //} else if (is_struct(_next_struct)) {
                //// Continue exploring deeper
                //explore_struct(_next_struct, _new_path);
            //}
        //}
    //}
    //
    //explore_struct(global.Upgrades, []);
    //return _all_paths;
//}
//
// Function to count the total number of possible upgrade types
function count_upgrade_types() {
    var _paths = find_all_upgrade_paths();
    show_debug_message("Total unique upgrade types: " + string(array_length(_paths)));
    
    // Count by systems
    var _system_counts = {};
    for (var _i = 0; _i < array_length(_paths); _i++) {
        var _path = _paths[_i].path;
        var _system = _path[0];
        
        if (!variable_struct_exists(_system_counts, _system)) {
            variable_struct_set(_system_counts, _system, 0);
        }
        
        var _current_count = variable_struct_get(_system_counts, _system);
        variable_struct_set(_system_counts, _system, _current_count + 1);
    }
    
    // Display counts by system
    var _system_names = variable_struct_get_names(_system_counts);
    for (var _j = 0; _j < array_length(_system_names); _j++) {
        var _sys_name = _system_names[_j];
        var _count = variable_struct_get(_system_counts, _sys_name);
        show_debug_message("System '" + _sys_name + "' has " + string(_count) + " upgrade types");
    }
    
    return _paths;
}

//// Enhanced function that applies the upgrade to the game
//function apply_upgrade(_upgrade) {
    //if (is_undefined(_upgrade)) return false;
    //
    //for (var _i = 0; _i < array_length(_upgrade.mods); _i++) {
        //var _mod = _upgrade.mods[_i];
        //
        //// Check if the mod has a target variable
        //if (variable_struct_exists(_mod, "target_var") && _mod.target_var != "") {
            //var _target_var = _mod.target_var;
            //var _current_value = variable_global_get(_target_var);
            //var _new_value;
            //
            //// Handle different value types
            //if (_mod.value_type == "boolean") {
                //// For boolean values, set directly
                //_new_value = (_mod.value == VALUE.TRUE);
            //} else {
                //// For numeric values, add to current
                //_new_value = _current_value + _mod.value;
            //}
            //
            //// Apply the new value
            //variable_global_set(_target_var, _new_value);
            //show_debug_message("Applied upgrade: " + _mod.desc + " to " + _target_var + 
                              //" (Old: " + string(_current_value) + ", New: " + string(_new_value) + ")");
        //} else {
            //// Handle mods without specific target variables (generic effects)
            //show_debug_message("Applied generic upgrade: " + _mod.desc);
            //// You would add specific code here to handle different types of generic upgrades
        //}
    //}
    //
    //return true;
//}
//
// Helper function to find all possible upgrade paths (for debugging)
//function find_all_upgrade_paths() {
    //var all_paths = [];
    //
    //function explore_struct(struct, current_path) {
        //var keys = variable_struct_get_names(struct);
        //
        //for (var i = 0; i < array_length(keys); i++) {
            //var key = keys[i];
            //
            //// Skip name and desc properties
            //if (key == "name" || key == "desc") continue;
            //
            //var next_struct = variable_struct_get(struct, key);
            //var new_path = [];
            //array_copy(new_path, 0, current_path, 0, array_length(current_path));
            //array_push(new_path, key);
            //
            //if (variable_struct_exists(next_struct, "value")) {
                //// Found a leaf node with a value
                //array_push(all_paths, {
                    //path: new_path,
                    //data: next_struct
                //});
            //} else if (is_struct(next_struct)) {
                //// Continue exploring deeper
                //explore_struct(next_struct, new_path);
            //}
        //}
    //}
    //
    //explore_struct(global.Upgrades, []);
    //return all_paths;
//}

// Enhanced function to generate an upgrade with debug information
function debug_generate_upgrade() {
    var result = generate_upgrade();
    if (result != undefined) {
        var all_paths = find_all_upgrade_paths();
        show_debug_message("Total possible upgrade paths: " + string(array_length(all_paths)));
        show_debug_message("Generated upgrade with " + string(array_length(result.mods)) + " mods");
        
        for (var i = 0; i < array_length(result.mods); i++) {
            show_debug_message("Mod #" + string(i+1) + ": " + result.mods[i].path_string);
        }
    }
    return result;
}

// Convert numeric rarity to named rarity
function rarity_from_value(value) {
    if (value <= 10) return "Common";
    else if (value <= 15) return "Uncommon";
    else if (value <= 20) return "Rare";
    else if (value <= 25) return "Epic";
    return "Legendary";
}

function rarity_to_color(rarity) {
    switch(rarity) {
        case "Common":    return c_gray;
        case "Uncommon":  return c_lime;
        case "Rare":      return c_blue;
        case "Epic":      return c_purple;
        case "Legendary": return c_orange;
        default:          return c_white;
    }
}

function generate_debug_upgrades_old()
{
    for (var i = 0; i < 10; i++) {
        var upg = generate_upgrade();
        if (!is_undefined(upg)) {
            show_debug_message("Upgrade: " + upg.name + " [" + upg.rarity + "]");
            for (var m = 0; m < array_length(upg.mods); m++) {
                var _mod = upg.mods[m];
                var polarity_text = (_mod.polarity == POLARITY.POSITIVE) ? "Positive" : "Negative";
                show_debug_message(" - Mod: " + _mod.name 
                    + ", Rarity: " + string(_mod.rarity) 
                    + ", Polarity: " + polarity_text
                    + ", Effect: " + _mod.desc 
                    + " by " + string(_mod.value * 100) + "%");
            }
        } else {
            show_debug_message("Upgrade generation failed - struct not found or incomplete.");
        }
    } 
}
