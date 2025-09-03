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

#macro CHATTERBOX_VERSION  "3.1.3 (beta)"
#macro CHATTERBOX_DATE     "2025-09-03"

#macro CHATTERBOX_CURRENT  (__ChatterboxSystem().__current)

#macro CHATTERBOX_ON_MOBILE  ((os_type == os_ios) || (os_type == os_android) || (os_type == os_tvos))
#macro CHATTERBOX_ON_WEB     (os_browser != browser_not_a_browser)

#macro CHATTERBOX_RUNNING_FROM_IDE  (GM_build_type == "run")