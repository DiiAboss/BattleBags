// Script Created By DiiAboss AKA Dillon Abotossaway
///@function   
///
///@description
///
///@param {id} _self
///
///@return
/// @function check_and_apply_upgrades()
/// @description Waits for upgrade menu to close, then applies next upgrade.
function check_and_apply_upgrades(_self)
{
    // Only run if the player has pending upgrades
    if (_self.target_level > 0 && !global.in_upgrade_menu && combo == 0) {
        
        // ✅ **Spawn the upgrade menu**
        bring_up_upgrade_menu();
        
        // ✅ **Track that we are inside the upgrade menu**
        global.in_upgrade_menu = true;
        
        // ✅ **Decrement the target level after closing**
        _self.target_level -= 1;
    }
}