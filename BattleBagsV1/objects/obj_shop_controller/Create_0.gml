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

Overworld_Upgrades =
{
    Coolant:
    {
        name: "Coolant",
        desc: "Coolsdown the engine, causing the speed to be reduces by 25% (increase rate will still apply)",
        price: 100,
        sprite: spr_coolant
    }
}

// Example of populating the shop (temporary placeholders)
for (var i = 0; i < 12; i++) {
    array_push(shop_items, {
        name: "Upgrade " + string(i+1),
        desc: "This upgrade will help your factory by improving production speed and efficiency. Would you like to purchase it?",
        price: (i+1) * 100,
        sprite: spr_none,
        type: "upgrade", // Could be "upgrade", "drone", etc.
        purchased: false,
        hovered: false,
    });
}

// Calculate max scroll based on number of items
max_items_visible = 8; // Maximum number of items visible at once
item_width = 96;
item_height = 96;
item_padding = 16;
max_scroll = max(0, (array_length(shop_items) - max_items_visible) * (item_width + item_padding));

// Item display area (centered horizontally, 1/3 of the way down the screen)
display_area_y = room_height * 0.2;
display_area_x = room_width * 0.5 - ((max_items_visible * (item_width + item_padding)) * 0.5);

// Text box dimensions
text_box_y = room_height * 0.5;
text_box_height = room_height * 0.25;
text_box_width = room_width * 0.9;
text_box_x = room_width * 0.05;

// Shop owner image box
shop_owner_box_width = 160;
shop_owner_box_height = 160;
shop_owner_box_x = text_box_x + 20;
shop_owner_box_y = text_box_y + (text_box_height - shop_owner_box_height) * 0.5;

// Buy button
buy_button_width = 120;
buy_button_height = 50;
buy_button_x = room_width - text_box_x - buy_button_width - 20;
buy_button_y = text_box_y + text_box_height - buy_button_height - 20;
buy_button_hover = false;

// Scroll buttons
left_scroll_btn_x = display_area_x - 40;
right_scroll_btn_x = display_area_x + (max_items_visible * (item_width + item_padding)) + 128;
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

