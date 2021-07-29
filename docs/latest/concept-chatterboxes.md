<h1 align="center">Chatterboxes</h1>

---

A chatterbox is a dialogue container, effectively a little virtual machine that lives inside your game. Chatterboxes handle story flow, they store dialogue content and options text, and they set variables and execute functions when directed to by [Yarn script](concept-yarn-script).

Chatterboxes are created with the [`ChatterboxCreate()`](reference-chatterboxes#chatterboxcreatefilename-singletontext-localscope) but chatterboxes **do not** need to be deleted, destroyed, or freed (unlike GameMaker's native [data structures](https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Drawing/Surfaces/Surfaces.htm) or [surfaces](https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Drawing/Surfaces/Surfaces.htm)). The memory that each chatterbox uses is automatically freed when you lose reference to the chatterbox (much like an array or a struct).

To initialise a chatterbox, call [`ChatterboxJump()`](reference-flow#chatterboxjumpchatterbox-nodetitle-filename) targetting the desired node. When you call [`ChatterboxJump()`](reference-flow#chatterboxjumpchatterbox-nodetitle-filename) (or in fact any of the [Flow functions](reference-flow)), the chatterbox runs your Yarn script a bit like a simple computer programme. The programme will continue running until one of three things happens:

1. The chatterbox has hit a `<<wait>>` command, or the chatterbox is in [singleton mode](reference-configuration#chatterboxcreatefilename-singletontext-localscope) and a line of dialogue has been processed
2. The Yarn script has hit a `<<stop>>` command or there's no more dialogue to show
3. The player needs to select an option

?> Chatterbox packages are distributed with [singleton mode](reference-configuration#chatterboxcreatefilename-singletontext-localscope) switched on by default. Please read the documentation on [`ChatterboxCreate()`](reference-chatterboxes#chatterboxcreatefilename-singletontext-localscope) and [`__ChatterboxConfig()`](reference-configuration#__chatterboxconfig) for more information.

Chatterbox provides three functions to find out what state a chatterbox is in, and they correspond to the list above:

1. If [`ChatterboxIsWaiting()`](reference-flow#chatterboxiswaitingchatterbox) is `true` then the chatterbox is waiting
2. If [`ChatterboxIsStopped()`](reference-flow#chatterboxisstoppedchatterbox) is `true` then the chatterbox has stopped
3. If [`ChatterboxGetOptionCount()`](reference-getters#chatterboxgetoptioncountchatterbox) is greater than 0 then the chatterbox has at least one [option](concept-yarn-script#option-syntax) that must be chosen to proceed

To advance the text and update a chatterbox's content and options, there are two functions available: [`ChatterboxContinue()`](reference-flow#chatterboxcontinuechatterbox) should be called when a chatterbox is waiting ([`ChatterboxIsWaiting()`](reference-flow#chatterboxiswaitingchatterbox) is `true`). To select an option, [`ChatterboxSelect()`](reference-flow#chatterboxselectchatterbox-optionindex) should be used. If a chatterbox has stopped then this indicates you should no longer show dialogue at all and gameplay should proceed.

Chatterboxes keep a copy of the content (text/dialogue) and options that should be shown to the player. These can be retrieved using the [Getter functions](reference-getters). A chatterbox will update its content and options whenever [`ChatterboxJump()`](reference-flow#chatterboxjumpchatterbox-nodetitle-filename), [`ChatterboxSelect()`](reference-flow#chatterboxselectchatterbox-optionindex), or [`ChatterboxContinue()`](reference-flow#chatterboxcontinuechatterbox) are called.

Exactly how the content and options are displayed, and how the player interacts with options, is entirely up to you. Chatterbox makes no assumptions about your text display system. Regardless of how you present content and options to the player, you should use the [Getter functions](reference-getters) to read the data from a chatterbox.
