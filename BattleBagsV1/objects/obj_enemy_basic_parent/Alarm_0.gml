/// @description Executes the pending attack after delay
if (self.pending_attack == "FREEZE") {
    execute_attack_on_targets(self, "FREEZE"); // ✅ Now safely executes the attack
    self.pending_attack = ""; // ✅ Reset after execution
}
