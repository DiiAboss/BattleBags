/// @description
if (room == rm_local_multiplayer_lobby)
{
    if !(instance_exists(obj_local_multiplayer_control))
    {
        instance_create_depth(depth-1, x, y, obj_local_multiplayer_control);
    }
}