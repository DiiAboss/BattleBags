/// @description

x = conveyor_x;



if !(active)
{
    if (hand_x < x)
    {
        hand_x += 1;
    }
    else {
        hand_x = x;
        hand_y = y;
    }

    
}