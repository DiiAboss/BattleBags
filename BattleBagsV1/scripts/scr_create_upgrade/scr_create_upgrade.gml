/// @desc Struct for an upgrade
///
/// @param _name
/// @param _desc
/// @param _effect
/// @param _rarity
/// @param _max_level

function create_upgrade(_name, _desc, _effect, _rarity, _max_level, _start_unlocked = false) {
    return {
        name: _name,
        desc: _desc,
        effect: _effect,
        rarity: _rarity,     // 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic, 5 = Legendary
        max_level: _max_level,
        level: 0,            // Start at level 0
        unlocked: _start_unlocked
    };
}