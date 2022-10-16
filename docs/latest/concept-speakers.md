# Speakers

Chatterbox offers three helper functions to assist with parsing content strings as dialogue:
- `ChatterboxGetContentSpeech()`
- `ChatterboxGetContentSpeaker()`
- `ChatterboxGetContentSpeakerData()`

A content string must be formatted in a specific way for Chatterbox's helper functions to work correctly. You can control the specific behaviour of this feature using [`CHATTERBOX_SPEAKER_DELIMITER`](reference-configuration?id=chatterbox_speaker_delimiter), [`CHATTERBOX_SPEAKER_DATA_START`](reference-configuration?id=chatterbox_speaker_data_start), and [`CHATTERBOX_SPEAKER_DATA_END`](reference-configuration?id=chatterbox_speaker_data_end), but by default Chatterbox expects lines of text to be in this format:

```yarn
Speaker Name: The words that the speaker is saying, called "speech" in Chatterbox.
```
  
Calling `ChatterboxGetContentSpeaker()` with the above string as the input will output `"Speaker Name"`. Calling `ChatterboxGetContentSpeech()` will output everything after the colon (though without the leading whitespace between the colon and `"The"`).

Chatterbox also offers "speaker data". This is an additional string that can be attached to a speaker for a content string. The formatting looks like this:

```yarn
Speaker Name[additional speaker data]: The words that the speaker is saying, called "speech" in Chatterbox.
```

Calling `ChatterboxGetContentSpeakerData()` will return "additional speaker data" in this case. For more complex situations you may want to perform additional parsing on the speaker data yourself e.g. splitting up the speaker data into an array.