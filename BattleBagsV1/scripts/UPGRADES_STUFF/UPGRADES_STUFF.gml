// Script Created By DiiAboss AKA Dillon Abotossaway
global.Overworld_Upgrades =
{
    Coolant:
    {
        name: "Coolant",
        desc: "Cools down the engine, causing the speed to be reduces by 25% (increase rate will still apply)",
        price: 100,
        sprite: spr_coolant,
        type: "consumable",
        req: "none",
        effect: function(player){
            player.game_speed_default -= (player.game_speed_default * 0.25);
        }
    },
    
    BugRepel:
    {
        name: "Bug Repel",
        desc: "No bugs will spawn for 30 seconds after use.",
        price: 100,
        sprite: spr_bug_repel,
        type: "consumable",
        req: "none",
        effect: function(player){
            player.repel_bugs_timer = 30 * room_speed;
        }
    },
    
    NegativeBooster:
    {
        name: "Negative Boost",
        desc: "When applied to an upgrade, reduce all effects by 25%",
        price: 100,
        sprite: spr_bug_repel,
        type: "consumable",
        req: "none",
        effect: function(player){
            player.repel_bugs_timer = 30 * room_speed;
        }
    },
    
    PositiveBooster:
    {
        name: "Positive Boost",
        desc: "When applied to an upgrade, increase all effects by 25%",
        price: 100,
        sprite: spr_bug_repel,
        type: "consumable",
        req: "none",
        effect: function(player){
            player.repel_bugs_timer = 30 * room_speed;
        }
    },
    
    DigitalSpinach:
    {
        name: "DigiSpinach",
        desc: "Increase the carry capacity of all drones by 1",
        price: 100,
        sprite: spr_digital_spinach,
        type: "drone",
        req: "none",
        apply_effect: function(player) {
            var num_drone = player.number_of_drones;
            for (var d = 0; d < num_drone; d++)
            {
                player.drone_array[d].mod_stats.carry_capacity += 0.25;
                
            }
            return "Drone Carry increased by 25%!";
        }
    },
    
    DigitalNRGDrink:
    {
        name: "DigiNRGDrink",
        desc: "Increase the drone speed by 5%",
        price: 100,
        sprite: spr_nrg_drink,
        type: "drone",
        req: "none",
        apply_effect: function(player)
        {
            var num_drone = player.number_of_drones;
                for (var d = 0; d < num_drone; d++) {
                    //show_debug_message(string(player.drone_array[d]))
                    player.drone_array[d].mod_stats.move_speed += 0.25;
                }
                return "Drone speed increased by 25%!";
        }
    },
    
    DroneMagnet:
    {
        name: "Drone Magnet",
        desc: "Drones attract nearby deposit blocks",
        price: 100,
        sprite: spr_none,
        type: "drone",
        req: "none",
        apply_effect: function(player)
        {
            var num_drone = player.number_of_drones;
                for (var d = 0; d < num_drone; d++) {
                    //show_debug_message(string(player.drone_array[d]))
                    player.drone_array[d].mod_stats.move_speed += 0.25;
                }
                return "Drone speed increased by 25%!";
        }
    },
    
    DroneStomache:
    {
        name: "Drone Stomache",
        desc: "Drones will eat a bad block every 30 seconds, granting 25% in all areas, if drone goes hungry -25% all stats",
        price: 100,
        sprite: spr_none,
        type: "drone",
        req: "none",
        apply_effect: function(player)
        {
            var num_drone = player.number_of_drones;
                for (var d = 0; d < num_drone; d++) {
                    //show_debug_message(string(player.drone_array[d]))
                    player.drone_array[d].mod_stats.move_speed += 0.25;
                }
                return "Drone speed increased by 25%!";
        }
    },
    
    RecyclerEfficiency:
    {
        name: "RecGem",
        desc: "Increase the deposit chance by 10%",
        price: 100,
        sprite: spr_none,
        type: "recycler",
        req: "none",
        apply_effect: function(player)
        {
            var recycler = player.recycler;
            player.recycler.success_chance_mod += 0.1;      
        }
    },
    
    UpgradeDepositChance:
    {
        name: "UpgDepoUp",
        desc: "Increase the spawn rate of all Upgrade Deposit Spheres by 1% (Decreases the block spawn chance)",
        price: 100,
        sprite: spr_powerup_up,
        type: "recycler",
        req: "none",
        apply_effect: function(player)
        {
            var recycler = player.recycler;
            player.recycler.mod_stats.success_chance += 0.1;      
        }
    },
    
    UpgradeDepositChance:
    {
        name: "BlkDepoUp",
        desc: "Increase the spawn rate of Deposit Blocks by 5% (Decreases the upgrades chance)",
        price: 100,
        sprite: spr_depo_up,
        type: "recycler",
        req: "none",
        apply_effect: function(player)
        {
            var recycler = player.recycler;
            player.recycler.success_chance_mod += 0.1;      
        }
    },
    
    BadBlockDepositChance:
    {
        name: "BadDepoDown",
        desc: "Decrease the spawn rate of BAD Deposit Blocks by 5%",
        price: 100,
        sprite: spr_depo_bad_down,
        type: "upgrade",
        req: "none",
        apply_effect: function(player)
        {
            var recycler = player.recycler;
            player.recycler.success_chance_mod += 0.1;      
        }
    },
    
    BigBlockAttractor:
    {
        name: "BBlockAttract",
        desc: "Any big blocks on board guarentee a block of the same color to spawn on the bottom row",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "bigblock",
        apply_effect: function(player){

        }
    },
    
    EP_Gainer:
    {
        name: "EP Gainer",
        desc: "Increase the amount of Energy Points gained per block (+10%)",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Match_Specialist:
    {
        name: "Match Spec",
        desc: "Increase the amount of Energy Points gained per match greater than 3 (+100%)",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Combo_Specialist:
    {
        name: "Combo Spec",
        desc: "Greatly Increase the amount of Energy Points gained per combo (+25%), but decrease the amount gained if no combo in progress (-50%)",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){
            
        }
    },
    
    Combo_Specialist_2:
    {
        name: "Combo Spec 2",
        desc: "Combo Timer is increased by 50%",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Combo_Explosion:
    {
        name: "Combo Explosion",
        desc: "Every multiple of 10x combo causes a guarenteed explosion",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Explosive_Master:
    {
        name: "Explosive Master",
        desc: "Source of explosions have a 25% chance to clear all blocks of that same type",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Color_Combo:
    {
        name: "Color Combo",
        desc: "Matches that consist of the same type as the first block in a combo are worth 25% more",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Color_Bomb_Spawn:
    {
        name: "ColorBomb",
        desc: "Color Bomb Spawns every 5 rows",
        price: 100,
        sprite: spr_wild_gem,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    More_Bows:
    {
        name: "More Bows",
        desc: "Bow Powerup Spawn Chance (+5%)",
        price: 100,
        sprite: spr_arrow,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    ComBows:
    {
        name: "ComBows",
        desc: "Bows Contribute to the total combo count",
        price: 100,
        sprite: spr_arrow,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    More_Bombs:
    {
        name: "More Bombs",
        desc: "Bomb Powerup Spawn Chance (+5%)",
        price: 100,
        sprite: spr_powerup_bomb,
        type: "engine",
        req: "Bombs",
        apply_effect: function(player){

        }
    },
    
    EP_Bombs:
    {
        name: "More Bombs",
        desc: "Bomb Powerup Spawn Chance (+5%)",
        price: 100,
        sprite: spr_powerup_bomb,
        type: "engine",
        req: "More Bombs",
        apply_effect: function(player){

        }
    },
    
    Bombs:
    {
        name: "Bombs Unlocked",
        desc: "Bomb Powerup Spawn Chance (+5%)",
        price: 100,
        sprite: spr_powerup_bomb,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Combo_Bombs:
    {
        name: "Combo Bombs",
        desc: "Bombs Contribute to the total combo count",
        price: 100,
        sprite: spr_powerup_bomb,
        type: "engine",
        req: "Combo Bombs",
        apply_effect: function(player){

        }
    },
    
    Money_Bombs:
    {
        name: "Combo Bombs",
        desc: "Bombs Contribute to the total combo count",
        price: 100,
        sprite: spr_powerup_bomb,
        type: "engine",
        req: "Combo Bombs",
        apply_effect: function(player){

        }
    },
    
    More_Ice:
    {
        name: "More Ice",
        desc: "Ice Cube Powerup Spawn Chance (+5%)",
        price: 100,
        sprite: spr_ice_cube,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    More_Gold_Blocks:
    {
        name: "More Coins",
        desc: "Coin Spawn Chance (+5%)",
        price: 100,
        sprite: spr_gold_coin,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Bad_Blocks_Give_EP:
    {
        name: "Bad=Good",
        desc: "When a bad block is converted, gain 1 EP",
        price: 100,
        sprite: spr_gameOver,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Big_Block:
    {
        name: "Big Block",
        desc: "2x2 matches create a big block, this block cannot be moved manually (This block is 4x heavier than normal blocks)",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){
            player.big_block_enabled = true;
        }
    },
    
    Shield_Block:
    {
        name: "Shield Block",
        desc: "A shield block that follows the players cursor location on the top row, pops any bad blocks that share the same space",
        price: 100,
        sprite: spr_shield_gem,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Oshki_Block:
    {
        name: "Oshki Block",
        desc: "Oshki Block will spawn with a match of 5 or more",
        price: 100,
        sprite: spr_Oshki,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Prism_Block:
    {
        name: "Prism Block",
        desc: "Prism blocks converts the whole row into the swapped color",
        price: 100,
        sprite: spr_prism_gem,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Heavy_Blocks:
    {
        name: "Heavy Blocks",
        desc: "Blocks are 100% Heavier",
        price: 100,
        sprite: spr_powerup_destroy_to_down,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Feather_Blocks:
    {
        name: "Feather Blocks",
        desc: "Blocks are 100% Lighter",
        price: 100,
        sprite: spr_powerup_feather,
        type: "engine",
        req: "none",
        apply_effect: function(player){

        }
    },
    
    Faster_Conveyor:
    {
        name: "Faster Belt",
        desc: "Conveyor Belt move blocks 50% faster",
        price: 100,
        sprite: spr_conveyor_tube,
        type: "conveyor",
        req: "none",
        apply_effect: function(player){
            player.conveyor.mod_stats.mod_speed += 0.5;
        }
    },
    
    Frequent_Shopper:
    {
        name: "Freq. Shopper",
        desc: "Future Shop Upgrades cost 10% less",
        price: 100,
        sprite: spr_none,
        type: "conveyor",
        req: "none",
        apply_effect: function(player){
            player.mod_stats.shop_price -= 0.10;
        }
    },
    
    Less_More:
    {
        name: "Less = More",
        desc: "The most uncommon block give 2x of all rewards",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){
            player.conveyor.mod_stats.mod_speed += 0.5;
        }
    },
    
    Resource_Conservation:
    {
        name: "ResourceSave",
        desc: "10% chance not to consume item when used",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){
            player.conveyor.mod_stats.mod_speed += 0.5;
        }
    },
    
    Depo_Block_Match:
    {
        name: "Deposit Match",
        desc: "Deposit Blocks can now match, giving EP for each block destroyed",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){
            player.conveyor.mod_stats.mod_speed += 0.5;
        }
    },
    
    Depo_Block_Combo:
    {
        name: "Deposit Combo",
        desc: "Deposit Blocks Matches give +1 to combo counter",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){
            player.conveyor.mod_stats.mod_speed += 0.5;
        }
    },
    
    Color_Resonance:
    {
        name: "Color Resonance",
        desc: "Consecutive Matches of the same color increases all rewards gained by 50% per match",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){
            player.conveyor.mod_stats.mod_speed += 0.5;
        }
    },
    
    Momentum_Engine:
    {
        name: "Momentum Engine",
        desc: "Every Move Reduces Momentum by 1, match give 3 momentum. gain 10% rewards per momentum point",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){
            player.conveyor.mod_stats.mod_speed += 0.5;
        }
    },
    
    Memory_Engine:
    {
        name: "Memory Engine",
        desc: "The engine remembers the last 3 types of blocks matched and increases their spawn rate by 5%",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){
            player.conveyor.mod_stats.mod_speed += 0.5;
        }
    },
    
    Critical_Match:
    {
        name: "Critical Match",
        desc: "Critical Match chance 5%, if triggered, will give 100% rewards",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){
            player.conveyor.mod_stats.mod_speed += 0.5;
        }
    },
    
    
    Expire_Block:
    {
        name: "Block_Expiry",
        desc: "Expire Blocks will now appear, these block will give 200% rewards when fresh, but will spawn flies if left untouched too long",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){
            player.conveyor.mod_stats.mod_speed += 0.5;
        }
    },
    
    Diagonal_Matches:
    {
        name: "Diagonal_Matches",
        desc: "Diagonal Matches Enabled",
        price: 100,
        sprite: spr_none,
        type: "engine",
        req: "none",
        apply_effect: function(player){
            player.conveyor.mod_stats.mod_speed += 0.5;
        }
    },
}
