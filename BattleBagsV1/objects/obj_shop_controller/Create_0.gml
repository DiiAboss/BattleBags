// CREATE EVENT
/// @description

// Shop initialization
shop_open = true;
horizontal_scroll = 0;
max_scroll = 0;
scroll_speed = 0.2;   // Lower values = smoother scrolling
hover_index = 0;      // Initially hovered item
target_scroll = 0;    // Target scroll position

// Selected item index
selected_item = -1;

// Placeholder item list
shop_items = array_create(0);

// Shop keeper dialogue variations
shopkeeper_phrases = {
    intro: [
        "This might be just what you need to boost your factory!",
        "I've been saving this one for a special customer.",
        "One of my most popular items, this is.",
        "This will certainly give you an edge!"
    ],
    recommend: [
        "I highly recommend this upgrade for your setup.",
        "This would complement your current systems perfectly.",
        "You won't regret investing in this one.",
        "My personal favorite - quality craftsmanship here."
    ],
    expensive: [
        "It's pricey, but worth every gold piece.",
        "Premium quality comes at a premium price.",
        "An investment that will pay for itself in no time.",
        "Only the finest materials went into making this."
    ]
};

Overworld_Upgrades =
{
    Coolant:
    {
        name: "Coolant",
        desc: "Cools down the engine, causing the speed to be reduces by 25% (increase rate will still apply)",
        price: 100,
        sprite: spr_coolant,
        type: "consumable",
        req: "none"
    },
    
    BugRepel:
    {
        name: "Bug Repellent",
        desc: "No bugs will spawn for 30 seconds after use.",
        price: 100,
        sprite: spr_coolant,
        type: "consumable",
        req: "none"
    },
    
    DigitalSpinach:
    {
        name: "Digital Spinach Gem",
        desc: "Increase the carry capacity of all drones by 25%",
        price: 100,
        sprite: spr_none,
        type: "drone",
        req: "none"
    },
    
    DigitalSpinach:
    {
        name: "Digital NRG Drink Gem",
        desc: "Increase the drone speed by 5%",
        price: 100,
        sprite: spr_none,
        type: "drone",
        req: "none"
    },
    
    RecyclerEfficiency:
    {
        name: "Recycler Efficiency Gem",
        desc: "Increase the deposit chance by 2.5%",
        price: 100,
        sprite: spr_none,
        type: "recycler",
        req: "none"
    },
    
    UpgradeDepositChance:
    {
        name: "Upgrade Deposit Chance",
        desc: "Increase the spawn rate of all Upgrade Deposit Spheres by 1% (Decreases the block spawn chance)",
        price: 100,
        sprite: spr_none,
        type: "recycler",
        req: "none"
    },
    
    UpgradeDepositChance:
    {
        name: "Block Deposit Chance",
        desc: "Increase the spawn rate of Deposit Blocks by 5% (Decreases the upgrades chance)",
        price: 100,
        sprite: spr_none,
        type: "recycler",
        req: "none"
    },
    
    BadBlockDepositChance:
    {
        name: "Bad Block Deposit Chance",
        desc: "Decrease the spawn rate of BAD Deposit Blocks by 5%",
        price: 100,
        sprite: spr_none,
        type: "upgrade",
        req: "none"
    },
    
    BigBlockAttractor:
    {
        name: "Big Block Attractor",
        desc: "Any big blocks on board guarentee a block of the same color to spawn on the bottom row",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "bigblock"
    },
    
    EP_Gainer:
    {
        name: "Energy Points Gainer",
        desc: "Increase the amount of Energy Points gained per block (+10%)",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none"
    },
    
    Combo_Specialist:
    {
        name: "Combo Specialist",
        desc: "Greatly Increase the amount of Energy Points gained per combo (+25%), but decrease the amount gained if no combo in progress (-50%)",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none"
    },
}

// Populate shop from Overworld_Upgrades structure
// This creates a fresh copy of each upgrade for this shop instance
var upgrade_names = variable_struct_get_names(Overworld_Upgrades);
for (var i = 0; i < array_length(upgrade_names); i++) {
    var upgrade_name = upgrade_names[i];
    var upgrade_data = Overworld_Upgrades[$ upgrade_name];
    
    // Create a fresh shop item instance from the upgrade data
    var shop_item = {
        name: upgrade_data.name,
        desc: upgrade_data.desc,
        shopkeeper_comment: get_shopkeeper_phrase(shopkeeper_phrases, irandom(2) == 0 ? "intro" : (irandom(1) == 0 ? "recommend" : "expensive")),
        price: upgrade_data.price,
        sprite: upgrade_data.sprite,
        type: upgrade_data.type,
        req: upgrade_data.req,
        purchased: false,
        hovered: false
    };
    
    array_push(shop_items, shop_item);
}

// Calculate max scroll based on number of items
max_items_visible = 8; // Maximum number of items visible at once
item_width = 96;
item_height = 96;
item_padding = 16;

// Group items by type for better organization
grouped_items = {};
for (var i = 0; i < array_length(shop_items); i++) {
    var item_type = shop_items[i].type;
    if (!variable_struct_exists(grouped_items, item_type)) {
        grouped_items[$ item_type] = [];
    }
    array_push(grouped_items[$ item_type], shop_items[i]);
}

// Flatten the grouped items back into shop_items
shop_items = [];
var type_names = variable_struct_get_names(grouped_items);
for (var i = 0; i < array_length(type_names); i++) {
    var type_items = grouped_items[$ type_names[i]];
    for (var j = 0; j < array_length(type_items); j++) {
        array_push(shop_items, type_items[j]);
    }
}

max_scroll = max(0, (array_length(shop_items) - max_items_visible) * (item_width + item_padding));

// Item display area (centered horizontally, 1/3 of the way down the screen)
display_area_y = window_get_height() * 0.33;
display_area_x = window_get_width() * 0.5 - ((max_items_visible * (item_width + item_padding)) * 0.5);

// Text box dimensions
text_box_y = window_get_height() * 0.7;
text_box_height = window_get_height() * 0.25;
text_box_width = window_get_width() * 0.9;
text_box_x = window_get_width() * 0.05;

// Shop owner image box
shop_owner_box_width = 160;
shop_owner_box_height = 160;
shop_owner_box_x = text_box_x + 20;
shop_owner_box_y = text_box_y + (text_box_height - shop_owner_box_height) * 0.5;

// Buy button
buy_button_width = 120;
buy_button_height = 50;
buy_button_x = window_get_width() - text_box_x - buy_button_width - 20;
buy_button_y = text_box_y + text_box_height - buy_button_height - 20;
buy_button_hover = false;

// Scroll buttons
left_scroll_btn_x = display_area_x - 40;
right_scroll_btn_x = display_area_x + (max_items_visible * (item_width + item_padding)) + 10;
scroll_btn_y = display_area_y + (item_height * 0.5);
scroll_btn_size = 30;
left_btn_hover = false;
right_btn_hover = false;

// Dialogue box
dialogue_text = "Welcome to my shop! I've got upgrades that will help your factory become more efficient.";

// Player currency (example)
player_currency = global.gold; // Assume global.gold exists

global.paused = true;

are_you_sure = false;
