function get_color_spawn_percentages(_self) {
    var total_weight = 0;
    var percentages = array_create(_self.numberOfGemTypes, 0);

    // ✅ Calculate total weight
    for (var i = 0; i < _self.numberOfGemTypes; i++) {
        total_weight += global.color_spawn_weight[i];
    }

    // ✅ Compute each color’s percentage
    for (var i = 0; i < _self.numberOfGemTypes; i++) {
        percentages[i] = (global.color_spawn_weight[i] / total_weight) * 100;
    }

    return percentages;
}

function draw_spawn_rates(_self) {
    var percentages = get_color_spawn_percentages(_self);
    
    draw_set_font(fnt_basic); // ✅ Use your custom font
    draw_set_color(c_white); // ✅ White text for visibility

    var start_x = _self.board_x_offset + (_self.width * gem_size) + 16;  // ✅ Left side of screen
    var start_y = 50;  // ✅ Top position
    var spacing = 20;  // ✅ Line spacing

    for (var i = 0; i < _self.numberOfGemTypes; i++) {
		
		var color_name = "";
		
		switch (i)
		{
			case BLOCK.RED:
				color_name = "RED";
			break;
			case BLOCK.YELLOW:
				color_name = "YELLOW";
			break;
			case BLOCK.GREEN:
				color_name = "GREEN";
			break;
			case BLOCK.PINK:
				color_name = "PINK";
			break;
			case BLOCK.PURPLE:
				color_name = "PURPLE";
			break;
			case BLOCK.LIGHTBLUE:
				color_name = "LIGHT BLUE";
			break;
			case BLOCK.ORANGE:
				color_name = "ORANGE";
			break;
			case BLOCK.BLUE:
				color_name = "BLUE";
			case BLOCK.WHITE:
				color_name = "WHITE";
			break;
			case BLOCK.BLACK:
				color_name = "BLACK";
			break;
			default:
				color_name = "WILD";
			break;
		}
        var text = string(color_name) + ": " + string(round(percentages[i])) + "%";
        draw_text(start_x, start_y + (i * spacing), text);
    }
}
