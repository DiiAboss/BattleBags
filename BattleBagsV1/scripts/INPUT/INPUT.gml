// Script Created By DiiAboss AKA Dillon Abotossaway

enum BUTTON_TYPE {
	NONE,
	MOUSE,
	KEYBOARD,
	GAMEPAD,
    ONLINE
}

function Input() constructor {
	ID              = -1;
	Name            = "";
	InputMap        = global.InputType.cKeyboard;
	ControllerMap   = global.InputType.cGamepad;
	Device          = -1;
	InputType       = INPUT.KEYBOARD;
	ButtonHold      = 10;

	// Movement Keys
	Up          = false;
	Left        = false;
	Down        = false;
	Right       = false;
	
	UpPress     = false;
	DownPress   = false;
	LeftPress   = false;
	RightPress  = false;

	// Main Action Key (Left Mouse Click & Controller RT + A)
	ActionKey       = false;
	ActionPress     = false;
	ActionRelease   = false;

	// Alternate Action Key (Mouse Right Click)
	AltKey          = false;
	AltPress        = false;
	AltRelease      = false;

	// Speed Up (Spacebar & Controller Left Trigger)
	SpeedUpKey      = false;

	// Skill Cycling (Bumpers & Mouse Wheel)
	CycleSkillUp    = false;
	CycleSkillDown  = false;
	cycleSkillDelay = 10; // Prevent fast scrolling issues

	// UI & Misc Inputs
	Back           = false;
	Escape         = false;
	Enter          = false;

	Direction      = 0;
	inputDelay     = 5;
    maxInputDelay  = 8;
	
    hover_x = 0;
    hover_y = 0;
	// Detect connected gamepad
	for (var cont = 0; cont < 12; cont++) {
		if (gamepad_is_connected(cont)) {
			Device = cont;
			break;
		}
	}
    
    static draw_device_num = function()
    {
        draw_text(room_width / 2, room_height / 2, string(Device));
    }

	static Update = function(_self, _x, _y) {
			if (InputType == INPUT.KEYBOARD) {
				// Movement Keys
				Up          = keyboard_check(InputMap.Up)    || keyboard_check(vk_up);
				Left        = keyboard_check(InputMap.Left)  || keyboard_check(vk_left);
				Right       = keyboard_check(InputMap.Right) || keyboard_check(vk_right);
				Down        = keyboard_check(InputMap.Down)  || keyboard_check(vk_down);

				UpPress     = keyboard_check_pressed(InputMap.Up)    || keyboard_check_pressed(vk_up);
				LeftPress   = keyboard_check_pressed(InputMap.Left)  || keyboard_check_pressed(vk_left);
				RightPress  = keyboard_check_pressed(InputMap.Right) || keyboard_check_pressed(vk_right);
				DownPress   = keyboard_check_pressed(InputMap.Down)  || keyboard_check_pressed(vk_down);

				// Action Keys
				ActionKey        = mouse_check_button(InputMap.ActionKey);
				ActionPress      = mouse_check_button_pressed(InputMap.ActionKey);
				ActionRelease    = mouse_check_button_released(InputMap.ActionKey);

				AltKey          = mouse_check_button(InputMap.AltKey);
				AltPress        = mouse_check_button_pressed(InputMap.AltKey);
				AltRelease      = mouse_check_button_released(InputMap.AltKey);

				// Speed Up Key
				SpeedUpKey      = keyboard_check(InputMap.SpeedUpKey);

				// Skill Cycling (Mouse Wheel)
				if (cycleSkillDelay <= 0) {
					CycleSkillUp   = mouse_wheel_up();
					CycleSkillDown = mouse_wheel_down();
					if (CycleSkillUp || CycleSkillDown) {
						cycleSkillDelay = 10; // Reset delay
					}
				} else {
					cycleSkillDelay -= 1;
				}

				// Other Inputs
				Back            = keyboard_check_pressed(InputMap.Back);
				Escape          = keyboard_check_pressed(InputMap.Escape);
				Enter           = keyboard_check_pressed(InputMap.Enter);

				// Mouse Direction
				//Direction       = point_direction(_x, _y, mouse_x, mouse_y);
//
				//// Switch to gamepad if button pressed
				//if (Device != -1 && gamepad_check_input(Device)) {
					//InputType = INPUT.GAMEPAD;
				//}
			}

			if (InputType == INPUT.GAMEPAD) {
				// Movement Keys
				Up          = gamepad_button_check(Device, ControllerMap.Up)    || (gamepad_axis_value(Device, gp_axislv) < -0.5);
				Left        = gamepad_button_check(Device, ControllerMap.Left)  || (gamepad_axis_value(Device, gp_axislh) < -0.5);
				Right       = gamepad_button_check(Device, ControllerMap.Right) || (gamepad_axis_value(Device, gp_axislh) > 0.5);
				Down        = gamepad_button_check(Device, ControllerMap.Down)  || (gamepad_axis_value(Device, gp_axislv) > 0.5);

				UpPress     = gamepad_button_check_pressed(Device, ControllerMap.Up);
				LeftPress   = gamepad_button_check_pressed(Device, ControllerMap.Left);
				RightPress  = gamepad_button_check_pressed(Device, ControllerMap.Right);
				DownPress   = gamepad_button_check_pressed(Device, ControllerMap.Down);

				// Action Keys
				ActionKey       = gamepad_button_check(Device, ControllerMap.ActionKey);
				ActionPress     = gamepad_button_check_pressed(Device, ControllerMap.ActionKey);
				ActionRelease   = gamepad_button_check_released(Device, ControllerMap.ActionKey);

				AltKey          = gamepad_button_check(Device, ControllerMap.AltKey);
				AltPress        = gamepad_button_check_pressed(Device, ControllerMap.AltKey);
				AltRelease      = gamepad_button_check_released(Device, ControllerMap.AltKey);

				// Speed Up (Left Trigger)
				SpeedUpKey      = gamepad_button_check(Device, ControllerMap.SpeedUpKey);

				// Skill Cycling (Bumpers)
				CycleSkillUp   = gamepad_button_check(Device, ControllerMap.CycleSkillUp);
				CycleSkillDown = gamepad_button_check_pressed(Device, ControllerMap.CycleSkillDown);

				// Back & UI Navigation
				//Back            = gamepad_button_check_pressed(Device, ControllerMap.Back);
				Escape          = gamepad_button_check_pressed(Device, ControllerMap.Escape);

				// Gamepad Direction
				var rhAxis = gamepad_axis_value(Device, gp_axisrh);
				var rvAxis = gamepad_axis_value(Device, gp_axisrv);
				//Direction  = point_direction(_x, _y, _x + rhAxis, _y + rvAxis);

				//// Switch to keyboard if any key is pressed
				//if (keyboard_check_pressed(vk_anykey)) {
					//InputType = INPUT.KEYBOARD;
				//}
            }
    }
}

enum INPUT {
	NONE,
	KEYBOARD,
	GAMEPAD,
    ONLINE
}

global.InputType = {
	cKeyboard: {
		ID:    INPUT.KEYBOARD,
		Name:  "Keyboard",

		// Movement Keys
		Up:      ord("W"),
		Left:    ord("A"),
		Down:    ord("S"),
		Right:   ord("D"),

		// Action Keys
		ActionKey:     mb_left,  // Left Mouse Click
		AltKey:        mb_right, // Right Mouse Click
		SpeedUpKey:    vk_space, // Spacebar (Speed Up)

		// Skill Cycling
		CycleSkillUp:   -1, // Mouse Wheel Up
		CycleSkillDown: -1, // Mouse Wheel Down

		// UI & Controls
		Back:        ord("F"),
		Escape:      vk_escape,
		Enter:       vk_enter
	},

	cGamepad: {
		ID:    INPUT.GAMEPAD,
		Name:  "Controller",

		// Movement Keys
		Up:      gp_padu,
		Left:    gp_padl,
		Down:    gp_padd,
		Right:   gp_padr,

		// Action Buttons
		ActionKey:    gp_face1,  // A Button
        ActionPress:    gp_face1,  // A Button
        ActionRelease:  gp_face1,  // A Button
		AltKey:        gp_face2,  // B Button

		SpeedUpKey:   gp_shoulderrb, // Left Trigger (Speed Up)

		// Skill Cycling (Bumpers)
		CycleSkillUp:   gp_shoulderr, // Right Bumper
		CycleSkillDown: gp_shoulderlb, // Left Bumper

		Escape:      gp_start,
		Enter:       gp_select
	}
}


function gamepad_check_input(_pad_num) {
    ///@desc    checks for gamepad input on the passed pad number
    ///@arg    pad_num    real    pad number to check
    
    for ( var i = gp_face1; i <= gp_padr; i++ ) {
        if ( gamepad_button_check( _pad_num, i ) ) return true;
    }
    for ( var i = gp_axislh; i <= gp_axisrv; i++ ) {
        if abs( gamepad_axis_value( _pad_num, i ) ) return true;
    }
}
