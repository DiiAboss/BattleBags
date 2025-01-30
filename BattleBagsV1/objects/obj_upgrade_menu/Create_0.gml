/// @description Insert description here
// You can write your code in this editor
array_size = 3;
upgrade = array_create(array_size);



// ✅ Example Upgrades
ds_list_add(global.upgrades, create_upgrade("ire Blocks", "Red blocks deal extra damage", "fire_boost"));
ds_list_add(global.upgrades, create_upgrade("low Drop", "Blocks fall slower", "slow_fall"));
ds_list_add(global.upgrades, create_upgrade("ore Yellow", "Yellow blocks appear more often", "more_yellow"));
ds_list_add(global.upgrades, create_upgrade("Extra Time", "Increases game speed by 1 second", "extra_time"));

for (var i = 0; i < array_size; i++) {
    index = irandom(ds_list_size(global.upgrades) - 1);
    upgrade[i] = global.upgrades[| index];
}