# Source Files

---

Chatterbox uses [Yarn script](concept-yarn-script) to define and describe how your story should progress. Yarn script can be written by hand, but the best way to start with Yarn is to use an editor. The standard Yarn Editor tool is available on [Windows and MacOS](https://github.com/YarnSpinnerTool/YarnEditor/releases/), or as a [web-based editor](https://yarnspinnertool.github.io/YarnEditor/).

Chatterbox is able to load [Yarn script](concept-yarn-script) from two different formats - `.yarn` and `.json`.

*As of 2020-07-02, the Yarn development team have [stated](https://narrativegamedev.slack.com/archives/CB9SN0VUP/p1593651206099100) that they have deprecated `.json` Yarn files. Chatterbox will continue to support JSON for the forseeable future.*

Irrespective of what format you choose to export your [Yarn script](concept-yarn-script) in, source files should be included with your project as [Included Files](https://docs2.yoyogames.com/source/_build/2_interface/1_editors/included_files.html). These files can then be loaded using [`chatterbox_load_from_file()`](reference-setup#chatterbox_load_from_filefilename) and, once loaded, those files can then be referenced by other Chatterbox functions.

Chatterbox has some extended functionality regarding stories spread across multiple files - please see the [Yarn script](concept-yarn-script#links-between-nodes) page for more information.