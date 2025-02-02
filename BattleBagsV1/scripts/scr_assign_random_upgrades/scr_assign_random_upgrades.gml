function assign_random_upgrades() {
    var num_upgrades = ds_list_size(global.upgrades_list);
    if (num_upgrades < 3) return; // Ensure enough upgrades exist

    var chosen = ds_list_create(); // Stores selected indexes

    for (var i = 0; i < 3; i++) {
        var index = 0;
        do {
            index = irandom(num_upgrades - 1);
        } until (!ds_list_find_index(chosen, index)); // Ensure unique selection

        ds_list_add(chosen, index);
        global.selected_upgrades[i] = ds_list_find_value(global.upgrades_list, index);
    }

    ds_list_destroy(chosen); // Cleanup
}
