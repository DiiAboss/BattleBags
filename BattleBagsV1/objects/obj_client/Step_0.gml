/// @desc Client Step Logic
var input = obj_game_manager.input;
input.Update(self, x, y);
x = mouse_x;
y = mouse_y;




// 🔥 Send player input
if (input.ActionPress) {

    var data = ds_map_create();
    // The Data To Send To Server
    ds_map_add(data, "x", mouse_x);
    ds_map_add(data, "y", mouse_y);
    ds_map_add(data, "id", id);
    ds_map_add(data, "spr", sprite_index);
    
    send_map_over_UDP(self, data, DATA_TYPE.DEBUG);

}


