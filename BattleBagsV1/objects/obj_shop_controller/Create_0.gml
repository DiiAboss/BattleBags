/// @description



// Shop initialization
shop_open = true;
scroll_offset = 238;
max_scroll = 0;
max_scroll_default = 238;
target_scroll      = 0;
scroll_speed       = 0.2;   // Lower values = smoother scrolling
hover_index        = 0;     // Initially hovered item

// Selected item index
selected_item = -1;

// Placeholder item list
shop_items = array_create(0);

create_new_upgrade =
{
    name: "Upgrade " + string(i+1),
    desc: "Description for Upgrade " + string(i+1),
    price: (i+1) * 100,
    sprite: spr_none,
    type: "upgrade", // Could be "upgrade", "drone", etc.
    purchased: false,
    hovered: false, 
}

// Example of populating the shop (temporary placeholders)
for (var i = 0; i < 8; i++) {
    array_push(shop_items, {
        name: "Upgrade " + string(i+1),
        desc: "Description for Upgrade " + string(i+1),
        price: (i+1) * 100,
        sprite: spr_none,
        type: "upgrade", // Could be "upgrade", "drone", etc.
        purchased: false,
        hovered: false,
    });
}

// Dimensions for scrolling area
scroll_area_x = room_width * 0.5;
scroll_area_y = 512;
scroll_area_width = room_width * 0.5 - 32;
scroll_area_height = 416;

// Item dimensions
item_height = 80;
item_padding = 8;

// Dialogue box
dialogue_text = "Welcome! Browse my wares.";
dialogue_box_height = 512;

// Player currency (example)
player_currency = global.gold; // Assume global.gold exists

global.paused = true;

input_delay_max = 30;
input_delay = input_delay_max;
are_you_sure = false;
