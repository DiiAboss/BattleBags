// Function to get random shopkeeper phrase
function get_shopkeeper_phrase(shopkeeper_phrases, category) {
    var phrases = shopkeeper_phrases[$ category];
    var phrase_index = irandom(array_length(phrases) - 1);
    return phrases[phrase_index];
}