/// @description
if (surface_exists(surBase)) {
    surface_free(surBase);
}

if (surface_exists(surPass)) {
    surface_free(surPass);
}
// Clean up conveyor belt
if (instance_exists(conveyor_belt)) {
    instance_destroy(conveyor_belt);
}