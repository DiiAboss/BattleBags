/// @description
// Shop initialization
shop_open = true;
scroll_offset = 0;
max_scroll = 0;
scroll_speed = 20;

// Selected item index
selected_item = -1;

// Placeholder item list
shop_items = array_create(0);

// Example of populating the shop (temporary placeholders)
for (var i = 0; i < 8; i++) {
    array_push(shop_items, {
        name: "Upgrade " + string(i+1),
        desc: "Description for Upgrade " + string(i+1),
        price: (i+1) * 100,
        sprite: spr_none,
        type: "upgrade", // Could be "upgrade", "drone", etc.
        purchased: false
    });
}

// Dimensions for scrolling area
scroll_area_x = 100;
scroll_area_y = 120;
scroll_area_width = room_width - 200;
scroll_area_height = 400;

// Item dimensions
item_height = 80;
item_padding = 8;

// Dialogue box
dialogue_text = "Welcome! Browse my wares.";
dialogue_box_height = 100;

// Player currency (example)
player_currency = global.gold; // Assume global.gold exists

global.paused = true;