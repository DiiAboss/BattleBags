function resolve_board() {
    // We'll keep looping until no more matches are found
    var keepGoing = true;
    while (keepGoing) {
        // find_and_destroy_matches now returns 'true' if something was destroyed
        keepGoing = find_and_destroy_matches();
        if (keepGoing) {
            drop_blocks(self);
        }
    }
}