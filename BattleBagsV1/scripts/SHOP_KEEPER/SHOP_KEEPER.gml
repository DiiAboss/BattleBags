// Function to get random shopkeeper phrase
function get_shopkeeper_phrase(shopkeeper_phrases, category) {
    var phrases = shopkeeper_phrases[$ category];
    var phrase_index = irandom(array_length(phrases) - 1);
    return phrases[phrase_index];
}


function generate_color_block_upgrades() {
    var colors = {
        RED: { name: "Red", sprite: spr_red_gem, type: BLOCK.RED },
        GREEN: { name: "Green", sprite: spr_green_gem, type: BLOCK.GREEN  },
        YELLOW: { name: "Yellow", sprite: spr_yellow_gem, type: BLOCK.YELLOW  },
        PINK: { name: "Pink", sprite: spr_pink_gem, type: BLOCK.PINK  },
        PURPLE: { name: "Purple", sprite: spr_purple_gem, type: BLOCK.PURPLE  },
        ORANGE: { name: "Orange", sprite: spr_orange_gem, type: BLOCK.ORANGE  },
        LIGHTBLUE: { name: "Light Blue", sprite: spr_lightblue_gem, type: BLOCK.LIGHTBLUE  },
        BLUE: { name: "Blue", sprite: spr_blue_gem, type: BLOCK.BLUE  }
    };
    
    var color_names = variable_struct_get_names(colors);
    var color_upgrades = {};
    
    for (var i = 0; i < array_length(color_names); i++) {
        var color_key = color_names[i];
        var color_data = colors[$ color_key];
        
        var upgrade_key = "More" + color_data.name;
        color_upgrades[$ upgrade_key] = {
            name: "More " + color_data.name,
            desc: "Increases the spawn rate of " + color_data.name + " blocks by 5%",
            price: 100,
            sprite: color_data.sprite,
            type: "engine",
            req: "none",
            color_key: color_data.type,  // Store the BLOCK enum key for reference
            apply_effect: function(player)
            {
                var color = other.color_key;
                player.block_spawn_rates.mod_weight_array[color] += 0.25;
                return string(other.name) + " increased by 25%!";
            }
            
        };
    }
    
    return color_upgrades;
}