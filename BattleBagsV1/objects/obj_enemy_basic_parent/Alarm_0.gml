/// @description Executes the pending attack after delay
if (self.pending_attack == "FREEZE") {
    execute_attack_on_targets(self, "FREEZE"); // ✅ Now safely executes the attack
    self.pending_attack = ""; // ✅ Reset after execution
}

if (self.pending_attack == "SLIME") {
    execute_attack_on_targets(self, "SLIME"); // ✅ Now safely executes the attack
    self.pending_attack = ""; // ✅ Reset after execution
}

