/// @function enemy_defeated
/// @description Handles enemy defeat.
function enemy_defeated(_self, game_control_object) {
    // ✅ Grant Rewards
    //global.gold += gold_reward;
    game_control_object.target_experience_points += exp_reward;

    // ✅ Destroy enemy
	instance_create_depth(x, y, depth, obj_test_enemy);
    instance_destroy();
}