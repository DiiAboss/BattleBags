function create_attack_projectile(x_start, y_start, color, damage)
{
    // ✅ Create Attack Object with Score
    var attack = instance_create_layer(x_start, y_start, "attacks", obj_player_attack);
    
    attack.color = color;
    
    attack.damage = damage; // 🔥 **Apply multiplier to damage!**
}
