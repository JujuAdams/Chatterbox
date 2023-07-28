// Feather disable all
function __ChatterboxMetadataStringIsLineHash(_string)
{
    return ((string_copy(_string, 1, __CHATTERBOX_LINE_HASH_PREFIX_LENGTH) == __CHATTERBOX_LINE_HASH_PREFIX) && (string_length(_string) == __CHATTERBOX_LINE_HASH_PREFIX_LENGTH + CHATTERBOX_LINE_HASH_SIZE));
}
