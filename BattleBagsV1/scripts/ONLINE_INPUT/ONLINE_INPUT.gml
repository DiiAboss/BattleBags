// Script Created By DiiAboss AKA Dillon Abotossaway
function Online_Input() constructor {
    ID              = -1;
    Name            = "";
    InputMap        = -1;
    ControllerMap   = -1;
    Device          = -1;
    InputType       = INPUT.ONLINE;
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
    
    static draw_device_num = function()
    {
        draw_text(room_width / 2, room_height / 2, string(Device));
    }

    static Update = function(up, left, down, right, action_key, action_release, speed_up_key) {

                Up          = up;
                Left        = left;
                Right       = right;
                Down        = down;

                UpPress     = up;
                LeftPress   = left;
                RightPress  = right;
                DownPress   = down;

                // Action Keys
                ActionKey        = action_key;
                ActionPress      = action_key;
                ActionRelease    = action_release;

                AltKey          = -1;
                AltPress        = -1;
                AltRelease      = -1;

                // Speed Up Key
                SpeedUpKey      = speed_up_key


                // Other Inputs
                Back            = -1;
                Escape          = -1;
                Enter           = -1;
            
    }
}
