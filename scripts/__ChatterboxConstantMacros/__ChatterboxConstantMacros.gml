// Feather disable all

#macro __CHATTERBOX_VERSION  "2.14.0"
#macro __CHATTERBOX_DATE     "2024-06-14"

#macro CHATTERBOX_VARIABLES_MAP   (__ChatterboxSystem().__variablesMap)
#macro CHATTERBOX_VARIABLES_LIST  (__ChatterboxSystem().__variablesList)
#macro CHATTERBOX_CURRENT         (__ChatterboxSystem().__current)

#macro __CHATTERBOX_DEBUG_INIT      false
#macro __CHATTERBOX_DEBUG_LOADER    false
#macro __CHATTERBOX_DEBUG_SPLITTER  false
#macro __CHATTERBOX_DEBUG_COMPILER  false
#macro __CHATTERBOX_DEBUG_VM        false

//These macros control which delimiters to use for <<actions>>
//You probably don't want to change these
#macro __CHATTERBOX_ACTION_OPEN_DELIMITER   "<"
#macro __CHATTERBOX_ACTION_CLOSE_DELIMITER  ">"

#macro __CHATTERBOX_LINE_HASH_PREFIX         "line:"
#macro __CHATTERBOX_LINE_HASH_PREFIX_LENGTH  5
#macro __CHATTERBOX_TEXT_HASH_LENGTH         6

#macro __CHATTERBOX_OPTION_CHOSEN_PREFIX  "optionChosen:"

#macro __CHATTERBOX_ON_MOBILE  ((os_type == os_ios) || (os_type == os_android) || (os_type == os_tvos))
#macro __CHATTERBOX_ON_WEB     (os_browser != browser_not_a_browser)