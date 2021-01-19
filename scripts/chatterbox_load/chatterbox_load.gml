function chatterbox_load(_filename)
{
    __chatterbox_error("chatterbox_load() has been deprecated. Please use chatterbox_load_from_file() instead");
    
    return chatterbox_load_from_file(_filename);
}