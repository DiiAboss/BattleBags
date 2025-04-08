/// @description Update deposit block state

// This function creates the push effect
function create_push_effect(_x, _y, _strength) {
    // Create an invisible object that will handle the push effect
    var push_obj = instance_create_depth(_x, _y, depth-10, obj_push_effect);
    
    // Set properties based on strength (number of blocks destroyed)
    push_obj.radius = 32;  // 32 pixel range as you specified
    push_obj.push_strength = min(5, 1 + (_strength - 3) * 0.5);  // Scale strength based on blocks destroyed
    push_obj.push_duration = 10;  // Effect lasts for 10 frames
}


if (global.paused)
{
    x = xprevious;
    y = yprevious;
    return;
}

image_angle = rotation;
x -= 0.1 * rotation_speed;
rotation += rotation_speed;
if (rotation > 360) rotation = 0;
if (rotation < 0) rotation = 360;

var block_size = scale;
var half_block_size = block_size * 0.5;

var block_below = collision_rectangle(x - half_block_size, y + half_block_size, x + half_block_size, y  + block_size, obj_deposit_block, false, true);

if (block_below != noone)
{
    if (block_below.falling == false)
    {
        base = block_below.y - (block_size + 1);
    }
    else {
        falling = block_below.falling;
        vsp = block_below.vsp;
    }
}
else {
    base = default_base;
}

var grv = 0;
if (abs(vsp) < 1 && (y >= base - 1))
{
    y = base;
    vsp = 0;
    falling = false;
    var dist_to_bottom = abs(y - default_base);
    var blocks_to_bottom = dist_to_bottom / scale;
    
    if (blocks_to_bottom > 1)
    {
        var half_plus_one = (scale);
        
        var half_size = scale * 0.5;

       if !(collision_rectangle(x, y + half_size, x - scale, y + scale, obj_deposit_block, false, true))  
       {
           x --;
           rotation_speed += 0.25;
       }
       else 
        if !(collision_rectangle(x, y + half_size, x + scale, y + scale, obj_deposit_block, false, true)) 
        {
          if (x+1 < room_width - scale)
          {
               x ++;
               rotation_speed -= 0.05; 
          }
       }
    }
    rotation_speed *= 0.9;
}
else {
    
    if (y <= base)
    {
        grv = 0.2;
        vsp += grv;
        rotation_speed *= 1.005;
        
    }
    
    if (y > base)
    {
        rotation_speed *= 0.999;
        vsp = -vsp * 0.5;
    }
    y += vsp;
}


if !(falling)
{
    if (y < base)
    {
        falling = true;
    }
    else {
        y = base;
        grv = 0;
        vsp = 0;
        gravity = 0;
        speed = speed * 0.5;
    }
}

// Conveyor belt movement adjustments
if (x > room_width - 32) {
    x -= 4;
    direction = 180;
}
if (x < room_width * 0.5) {
    x+= 4;
    direction = 0;
}



// Sparkle effect timer (when block is ready)
if (state == "ready") {
    sparkle_timer++;
    if (sparkle_timer >= sparkle_interval) {
        sparkle_timer = 0;
        var sparkle_x = x + irandom_range(-16, 16);
        var sparkle_y = y - 16 + irandom_range(-8, 8);
        //effect_create_above(ef_star, sparkle_x, sparkle_y, 0, c_white);
    }
}

// State updates
switch(state) {
    case "cooldown":
        // Increment regeneration timer
        regen_timer++;
        
        // Check if regeneration is complete
        if (regen_timer >= max_regen_time) {
            state = "ready";
            
            // Create effect to show block is ready
            //effect_create_above(ef_ring, x, y - 16, 0, c_white);
        }
        break;
        
    case "depleted":
        // Increment depletion recovery timer
        depletion_timer++;
        
        // Check if depletion recovery is complete
        if (depletion_timer >= max_depletion_time) {
            state = "ready";
            current_block_type = choose_weighted_block_type(obj_recycler.deposit_blocks);
            
            // Create effect to show source is active again
            repeat(5) {
                var effect_x = x + irandom_range(-24, 24);
                var effect_y = y + irandom_range(-24, 0);
                //effect_create_above(ef_firework, effect_x, effect_y, 0, c_white);
            }
        }
        break;
}
