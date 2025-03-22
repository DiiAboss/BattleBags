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
    POSITIVE    
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
            increase:
            { 
                name: "Increase",
                desc: "Increase the speed of the recycler output",
                value: 0.05,
                pol: POLARITY.POSITIVE,
                rarity: 10
            },
            
            decrease:
            {
                name: "Decrease",
                desc: "Reduce the speed of the recycler output",
                value: 0.05,
                pol: POLARITY.POSITIVE,
                rarity: 10
            }
        },
        
        bad_block:
        {
            chance:
            {
                name: "Chance",
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
                }
            }
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
                    value: 0.04,
                    pol: POLARITY.POSITIVE,
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
                    value: 0.03,
                    pol: POLARITY.POSITIVE,
                    rarity: 20
                }
            }
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
                    value: 0.05,
                    pol: POLARITY.NEGATIVE,
                    rarity: 10
                }
            }
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
                decrease: { name: "Decrease", desc: "Slow down the grid shift rate", value: 1.05, rarity: 10, pol: POLARITY.POSITIVE }
            }
        }
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
        }
    },

    drones:
    {
        speed:
        {
            name: "Speed",
            desc: "Increase drone movement speed",
            value: 0.05,
            pol: POLARITY.POSITIVE,
            rarity: 10
        },
        carry_capacity:
        {
            name: "Carry Capacity",
            desc: "Increase the amount drones can carry",
            value: 1,
            pol: POLARITY.POSITIVE,
            rarity: 15
        }
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

    powerups:
    {
        spawn_chance:
        {
            name: "Spawn Chance",
            desc: "Increase powerup spawn chance",
            value: 0.02,
            pol: POLARITY.POSITIVE,
            rarity: 15
        }
    },

    skills:
    {
        cooldown_reduction:
        {
            name: "Cooldown Reduction",
            desc: "Reduce cooldown of skills",
            value: 0.05,
            pol: POLARITY.POSITIVE,
            rarity: 15
        }
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

function generate_upgrade() {

    // Start by randomly picking a system
    var system_keys = variable_struct_get_names(global.Upgrades);
    var attempts = 50; // avoid infinite loops
    var final_struct = undefined;

    while (attempts > 0) {
        var path = []; // to store the keys we follow
        var current_struct = global.Upgrades;

        // Step downwards until we find a struct with a "value"
        while (!variable_struct_exists(current_struct, "value")) {
            var keys = variable_struct_get_names(current_struct);
            var valid_keys = [];
            for (var i = 0; i < array_length(keys); i++) {
                if (keys[i] != "name" && keys[i] != "desc") {
                    array_push(valid_keys, keys[i]);
                }
            }

            if (array_length(valid_keys) == 0) break; // no further keys, invalid path
            
            var chosen_key = array_random(valid_keys);
            array_push(path, chosen_key);
            current_struct = variable_struct_get(current_struct, chosen_key);
        }

        // Found a valid struct with "value"
        if (variable_struct_exists(current_struct, "value")) {
            final_struct = current_struct;
            break;
        }
        
        attempts--;
    }

    if (final_struct == undefined) {
        show_debug_message("Upgrade generation failed after multiple attempts.");
        return undefined;
    }

    // Now build the upgrade data
    var system = path[0]; // top-level system
    var property = (array_length(path) > 1) ? path[1] : "General";
    var modifier = (array_length(path) > 2) ? path[2] : "Default";

    // Manufacturer fallback
    var manufacturer_list = variable_struct_exists(global.Manufacturers, system)
        ? variable_struct_get(global.Manufacturers, system)
        : global.Manufacturers.alt;
    var maker = array_random(manufacturer_list);

    var upgrade_mod = {
        system: system,
        property: property,
        modifier_key: modifier,
        name: final_struct.name,
        desc: final_struct.desc,
        value: final_struct.value,
        polarity: final_struct.pol,
        rarity: final_struct.rarity
    };

    var rarity = rarity_from_value(upgrade_mod.rarity);
    var mod_color = (upgrade_mod.polarity == POLARITY.NEGATIVE) ? c_red : rarity_to_color(rarity);

    var full_name = maker + "'s " + upgrade_mod.name + " " + string_upper(property);

    return {
        name: full_name,
        mods: [upgrade_mod],
        rarity: rarity,
        color: mod_color,
        manufacturer: maker,
        system: system,
        property: property,
        desc: upgrade_mod.desc,
        value: upgrade_mod.value
    };
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


