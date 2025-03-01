// Only recreate surfaces when needed
if (!surface_exists(surBase) || 
    surface_get_width(surBase) != surface_get_width(application_surface) || 
    surface_get_height(surBase) != surface_get_height(application_surface)) {
    
    if (surface_exists(surBase)) surface_free(surBase);
    if (surface_exists(surPass)) surface_free(surPass);
    
    surBase = surface_create(surface_get_width(application_surface), 
                            surface_get_height(application_surface));
    surPass = surface_create(surface_get_width(application_surface), 
                            surface_get_height(application_surface));
}
