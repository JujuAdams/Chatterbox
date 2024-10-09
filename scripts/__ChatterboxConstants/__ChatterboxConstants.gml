// Feather disable all

////////////////////////////////////////////////////////////////////////////
//                                                                        //
// You're welcome to use any of the following macros in your game but ... //
//                                                                        //
//                       DO NOT EDIT THIS SCRIPT                          //
//                       Bad things might happen.                         //
//                                                                        //
//    Customisation options can be found in the Configuration script.     //
//                                                                        //
////////////////////////////////////////////////////////////////////////////

#macro CHATTERBOX_VERSION  "2.18.0"
#macro CHATTERBOX_DATE     "2024-10-09"

#macro CHATTERBOX_VARIABLES_MAP   (__ChatterboxSystem().__variablesMap)
#macro CHATTERBOX_VARIABLES_LIST  (__ChatterboxSystem().__variablesList)
#macro CHATTERBOX_CURRENT         (__ChatterboxSystem().__current)

#macro CHATTERBOX_ON_MOBILE  ((os_type == os_ios) || (os_type == os_android) || (os_type == os_tvos))
#macro CHATTERBOX_ON_WEB     (os_browser != browser_not_a_browser)