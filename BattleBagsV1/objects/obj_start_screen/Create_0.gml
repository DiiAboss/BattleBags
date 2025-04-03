// Create Event in obj_startScreen
button_width = 400;
button_height = 200;
button_spacing = 40;
button_x = room_width / 2 - (1.5 * button_width + button_spacing);
button_y = room_height / 2 - button_height / 2;
selected_button = ""; // Track hover state

// List of buttons
buttons = [
    {label: "DEPLOY", x: button_x, action: "deploy"},
    {label: "SHOP", x: button_x + button_width + button_spacing, action: "shop"},
    {label: "EXPLORE", x: button_x + 2 * (button_width + button_spacing), action: "explore"}
];
