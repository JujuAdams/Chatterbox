# Chatterboxes

---

A chatterbox is a dialogue container, effectively a little virtual machine that lives inside your game. Chatterboxes handle story flow, they store dialogue content and options text, and they set variables and execute functions when directed to by [Yarn script](concept-yarn-script).

Chatterboxes are created with the [`chatterbox_create()`](reference-chatterboxes#chatterbox_createfilename-singletontext) but chatterboxes **do not** need to be deleted, destroyed, or freed (unlike GameMaker's native [data structures](https://docs2.yoyogames.com/index.html?page=source%2F_build%2F3_scripting%2F4_gml_reference%2Fdrawing%2Fsurfaces%2Findex.html) or [surfaces](https://docs2.yoyogames.com/index.html?page=source%2F_build%2F3_scripting%2F4_gml_reference%2Fdrawing%2Fsurfaces%2Findex.html)). The memory that each chatterbox uses is automatically freed when you lose reference to the chatterbox (much like an array or a struct).

To initialise a chatterbox, call [`chatterbox_goto()`](reference-flow#chatterbox_gotochatterbox-nodetitle) targetting the desired node. When you call [`chatterbox_goto()`](reference-flow#chatterbox_gotochatterbox-nodetitle) (or in fact any of the [Flow functions](reference-flow)), the chatterbox runs your Yarn script a bit like a simple computer programme. The programme will continue running until one of three things happens:

1. The chatterbox has hit a `<<wait>>` command, or the chatterbox is in [singleton mode](reference-chatterboxes#chatterbox_createfilename-singletontext) and a line of dialogue has been processed
2. The Yarn script has hit a `<<stop>>` command or there's no more dialogue to show
3. The player needs to select an option

*Chatterbox packages are distributed with [singleton mode](reference-chatterboxes#chatterbox_createfilename-singletontext) switched on by default. Please read the documentation on [`chatterbox_create()`](reference-chatterboxes#chatterbox_createfilename-singletontext) and [`__chatterbox_config()`](reference-configuration#__chatterbox_config) for more information.*

Chatterbox provides three functions to find out what state a chatterbox is in, and they correspond to the list above:
1. If [`chatterbox_is_waiting()`](reference-flow#chatterbox_is_waitingchatterbox) is `true` then the chatterbox is waiting
2. If [`chatterbox_is_stopped()`](reference-flow#chatterbox_is_stoppedchatterbox) is `true` then the chatterbox has stopped
3. If [`chatterbox_get_option_count()`](reference-flow#chatterbox_get_option_countchatterbox) is greater than 0 then the chatterbox has at least one [option](concept-yarn-script#option-syntax) (or [shortcut](concept-yarn-script#menu-syntax)) that must be chosen to proceed

To advance the text and update a chatterbox's content and options, there are two functions available: [`chatterbox_continue()`](reference-flow#chatterbox_continuechatterbox) should be called when a chatterbox is waiting ([`chatterbox_is_waiting()`](reference-flow#chatterbox_is_waitingchatterbox) is `true`). To select an option, [`chatterbox_select()`](reference-flow#chatterbox_selectchatterbox-optionindex) should be used. If a chatterbox has stopped then this indicates you should no longer show dialogue at all and gameplay should proceed.

Chatterboxes keep a copy of the content (text/dialogue) and options that should be shown to the player. These can be retrieved using the [Getter functions](reference-getters)). A chatterbox will update its content and options whenever [`chatterbox_goto()`](reference-flow#chatterbox_gotochatterbox-nodetitle), [`chatterbox_select()`](reference-flow#chatterbox_selectchatterbox-optionindex), or [`chatterbox_continue()`](reference-flow#chatterbox_continuechatterbox) are called.

Exactly how the content and options are displayed, and how the player interacts with options, is entirely up to you. Chatterbox makes no assumptions about your text display system. Regardless of how you present content and options to the player, you should use the [Getter functions](reference-getters) to read the data from a chatterbox.