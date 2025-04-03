// Create Event in obj_intown_shop
menu_width = 300;
menu_x = 50;
menu_y = 100;
button_height = 60;
button_spacing = 10;
current_menu = "main";
selected_upgrade = -1;
scroll_offset = 0;

// Define main categories
main_menu = [
    {label: "RECYCLER", action: "recycler"},
    {label: "ENGINE", action: "engine"},
    {label: "SORTER", action: "sorter"},
    {label: "DRONES", action: "drones"},
    {label: "OTHER", action: "other"}
];

// Submenus (example upgrades per category)
submenus = array_create(array_length(main_menu), []);
submenus[0] = [
    {label: "Efficiency Boost", desc: "Increases recycling speed."},
    {label: "Energy Saver", desc: "Reduces energy consumption."}
];
submenus[1] = [
    {label: "Turbo Boost", desc: "Increases movement speed."}
];