


// Create Event in obj_intown_shop
menu_width = 300;
menu_x = 50;
menu_y = 100;
button_height = 60;
button_spacing = 10;
current_menu = "main";
current_submenu = "";
selected_upgrade = -1;
scroll_offset = 0;
max_upgrade_level = 5;

// Player currency (example)
player_currency = 10000;

// Button hover animation variables
hover_scale = 1.0;
hover_target_scale = 1.1;
hover_speed = 0.1;
hover_button_index = -1;
hover_alpha_pulse = 0;

// Buy confirmation
show_buy_confirm = false;
confirm_upgrade = "";
confirm_cost = 0;

// Define main categories using array of structs
main_menu = [
    {label: "ENGINE", action: "engine"},
    {label: "SORTER", action: "sorter"},
    {label: "DRONES", action: "drones"},
    {label: "OVERWORLD", action: "overworld"}
];

// Submenus for each category (using structs)
engine_submenu = [
    {label: "SHIFT SPEEDERS", action: "shift_speed", desc: "Increases your shift speed for block movement"},
    {label: "EP BOOSTERS", action: "ep_gain", desc: "Increases energy production from blocks"},
    {label: "SIZE", action: "can_2x2", desc: "Unlocks 2x2 block placement capability"}
];

sorter_submenu = [
    {label: "CONVEYOR SPEED", action: "conveyor_speed", desc: "Increases conveyor belt speed"},
    {label: "DIAGONAL MATCHES", action: "diagonal_matches", desc: "Enables diagonal block matching"},
    {label: "COMBO TIMER", action: "max_combo_timer", desc: "Extends combo duration"}
];

drones_submenu = [
    {label: "COLLECTOR DRONE", action: "collector_drone", desc: "Drone that collects blocks automatically"},
    {label: "ATTACKER DRONE", action: "attacker_drone", desc: "Drone that attacks threats automatically"},
    {label: "BUILDER DRONE", action: "builder_drone", desc: "Drone that helps with block placement"}
];

overworld_submenu = [
    {label: "FUEL EFFICIENCY", action: "overworld_speed", desc: "Increases movement efficiency in the overworld"},
    {label: "HEAT MANAGEMENT", action: "overheat_rate", desc: "Reduces engine overheating rate"},
    {label: "COOLANT SYSTEM", action: "overheat_cooldown", desc: "Improves cooling efficiency"}
];

// Upgrade data for each upgrade type
upgrades = {
    // Engine upgrades
    shift_speed: {
        level: 0,
        max_level: 5,
        base_cost: 100,
        cost_multiplier: 1.5,
        effects: [10, 20, 35, 50, 75] // % increase per level
    },
    
    ep_gain: {
        level: 0,
        max_level: 5,
        base_cost: 150,
        cost_multiplier: 1.6,
        effects: [10, 25, 45, 70, 100] // % increase per level
    },
    
    can_2x2: {
        level: 0,
        max_level: 1,
        base_cost: 500,
        cost_multiplier: 1,
        effects: [1] // boolean unlock
    },
    
    // Sorter upgrades
    conveyor_speed: {
        level: 0,
        max_level: 5,
        base_cost: 100,
        cost_multiplier: 1.5,
        effects: [10, 20, 30, 40, 50] // % increase per level
    },
    
    diagonal_matches: {
        level: 0,
        max_level: 1,
        base_cost: 300,
        cost_multiplier: 1,
        effects: [1] // boolean unlock
    },
    
    max_combo_timer: {
        level: 0,
        max_level: 5,
        base_cost: 150,
        cost_multiplier: 1.7,
        effects: [10, 20, 35, 50, 75] // % increase per level
    },
    
    // Overworld upgrades
    overworld_speed: {
        level: 0,
        max_level: 5,
        base_cost: 200,
        cost_multiplier: 1.8,
        effects: [10, 20, 30, 40, 50] // % increase per level
    },
    
    overheat_rate: {
        level: 0,
        max_level: 5,
        base_cost: 150,
        cost_multiplier: 1.8,
        effects: [5, 10, 15, 20, 25] // % decrease per level
    },
    
    overheat_cooldown: {
        level: 0,
        max_level: 5,
        base_cost: 200,
        cost_multiplier: 1.7,
        effects: [10, 20, 30, 40, 50] // % increase per level
    },
    
    // Drone upgrades
    collector_drone: {
        level: 0,
        max_level: 1,
        base_cost: 300,
        cost_multiplier: 1,
        effects: [1], // unlock drone
        sprite: spr_drone
    },
    
    attacker_drone: {
        level: 0,
        max_level: 1,
        base_cost: 400,
        cost_multiplier: 1,
        effects: [1], // unlock drone
        sprite: spr_eye_1
    },
    
    builder_drone: {
        level: 0,
        max_level: 1,
        base_cost: 500,
        cost_multiplier: 1,
        effects: [1], // unlock drone
        sprite: spr_guy_1
    }
};

// Unlocked drones array
unlocked_drones = [];

// Function to get the appropriate submenu based on current_menu
get_current_submenu = function() {
    switch(current_menu) {
        case "engine": return engine_submenu;
        case "sorter": return sorter_submenu;
        case "drones": return drones_submenu;
        case "overworld": return overworld_submenu;
        default: return [];
    }
}

// Apply upgrade effects to game stats
apply_upgrade_effects = function(upgrade_type, new_level) {
    var game_control = obj_game_manager;
    
    switch(upgrade_type) {
        case "shift_speed":
            game_control.mod_stats.shift_speed = 1 + (upgrades.shift_speed.effects[new_level-1] / 100);
            break;
            
        case "ep_gain":
            game_control.mod_stats.ep_gain = 1 + (upgrades.ep_gain.effects[new_level-1] / 100);
            break;
            
        case "can_2x2":
            game_control.can_2x2 = true;
            break;
            
        case "conveyor_speed":
            game_control.mod_stats.conveyor_speed = 1 + (upgrades.conveyor_speed.effects[new_level-1] / 100);
            break;
            
        case "diagonal_matches":
            game_control.diagonal_matches = true;
            break;
            
        case "max_combo_timer":
            game_control.mod_stats.max_combo_timer = 1 + (upgrades.max_combo_timer.effects[new_level-1] / 100);
            break;
            
        case "overworld_speed":
            game_control.mod_stats.overworld_speed = 1 + (upgrades.overworld_speed.effects[new_level-1] / 100);
            break;
            
        case "overheat_rate":
            game_control.mod_stats.overheat_rate = 1 - (upgrades.overheat_rate.effects[new_level-1] / 100);
            break;
            
        case "overheat_cooldown":
            game_control.mod_stats.overheat_cooldown = 0.25 * (1 + (upgrades.overheat_cooldown.effects[new_level-1] / 100));
            break;
            
        case "collector_drone":
        case "attacker_drone":
        case "builder_drone":
            create_drone(upgrade_type);
            break;
    }
}

// Function to create a drone based on type
create_drone = function(drone_type) {
    var game_control = obj_game_manager;
    var drone_data = upgrades[$ drone_type];
    
    var drone_properties = {
        collector_drone: {
            sprite: spr_drone,
            priority: "collecting",
            mods: [
                {
                    name: "Collector Module",
                    effect: function(_self) {
                        // Collector-specific behavior
                        _self.mod_stats.carry_capacity = 2;
                        _self.mod_stats.pickup_speed = 1.5;
                    }
                }
            ]
        },
        attacker_drone: {
            sprite: spr_eye_1,
            priority: "attacking",
            mods: [
                {
                    name: "Attack Module",
                    effect: function(_self) {
                        // Attacker-specific behavior
                        _self.stats.attack = true;
                        _self.mod_stats.attack_rate = 1.5;
                        _self.mod_stats.move_speed = 1.2;
                    }
                }
            ]
        },
        builder_drone: {
            sprite: spr_guy_1,
            priority: "building",
            mods: [
                {
                    name: "Builder Module",
                    effect: function(_self) {
                        // Builder-specific behavior
                        _self.mod_stats.throw_speed = 1.5;
                        _self.mod_stats.throw_distance = 1.3;
                    }
                }
            ]
        }
    };
    
    // Create a new drone using the constructor
    var new_drone = new Drone(
        obj_game_manager,  // player
        game_control.number_of_drones, // id
        room_width / 2, // x
        room_height / 2 // y
    );
    
    // Set drone properties based on type
    var props = drone_properties[$ drone_type];
    new_drone.my_sprite = props.sprite;
    new_drone.priority = props.priority;
    new_drone.mods = props.mods;
    
    // Apply any modules
    for (var i = 0; i < array_length(new_drone.mods); i++) {
        var _mod = new_drone.mods[i];
        if (_mod.effect != undefined) {
            _mod.effect(new_drone);
        }
    }
    
    // Add to unlocked drones array
    array_push(game_control.drone_array, new_drone);
    
    // Update game control
    game_control.number_of_drones++;
}

// Colors and visual settings
c_button = c_navy;
c_button_hover = c_blue;
c_button_text = c_white;
c_title = c_yellow;
c_description = c_white;
c_upgrade_available = c_green;
c_upgrade_maxed = c_red;
c_level_indicator = c_gray;
c_level_filled = c_yellow;
c_buy_button = c_green;
c_cancel_button = c_red;

// Sprites for the upgrade levels (you'll need to create these)
spr_upgrade_empty = spr_red_gem; // Empty upgrade level box
spr_upgrade_filled = spr_green_gem_1; // Filled upgrade level box
spr_upgrade_available = spr_blue_triangle; // Available to purchase

last_hovered = -1;