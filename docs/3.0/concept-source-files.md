# Source Files

---

Chatterbox uses [YarnScript](concept-chatterscript) to define and describe how your story should progress, and Chatterbox uses YarnScript version 2. YarnScript can be written by hand, but the best way to start with Yarn is to use an editor. The best editor to use with YarnScript v2 is [Crochet](https://github.com/FaultyFunctions/Crochet), available on [Windows, MacOS, & Ubuntu](https://github.com/FaultyFunctions/Crochet/releases), or as a [web-based editor](https://faultyfunctions.github.io/Crochet/).

Crochet exports `.yarn` files which contain the structure of your writing. Source files should be included with your project as [Included Files](https://manual.yoyogames.com/Settings/Included_Files.htm). These files can then be loaded using [`ChatterboxLoadFromFile()`](reference-configuration#chatterboxloadfromfilefilename-aliasname) and, once loaded, those files can then be referenced by other Chatterbox functions.

Chatterbox has some extended functionality regarding stories spread across multiple files - please see the [YarnScript](concept-chatterscript#links-between-nodes) page for more information.
