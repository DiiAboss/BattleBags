/// @description
if (part_type_exists(pt)) {
    part_type_destroy(pt);
}

if (ds_exists(fragments, ds_type_list)) {
    for (var i = 0; i < ds_list_size(fragments); i++) {
        var fragment_pt = ds_list_find_value(fragments, i);
        if (part_type_exists(fragment_pt)) {
            part_type_destroy(fragment_pt);
        }
    }
    ds_list_destroy(fragments);
}

instance_destroy();