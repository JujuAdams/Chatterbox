<img src="https://raw.githubusercontent.com/JujuAdams/Chatterbox/master/LOGO.png" width="50%" style="display: block; margin: auto;" />
<h1 align="center">2.14</h1>
<p align="center">Narrative engine for GameMaker 2022 LTS by <a href="https://www.jujuadams.com/" target="_blank">Juju Adams</a></p>

<p align="center"><a href="https://github.com/JujuAdams/chatterbox/releases/" target="_blank">Download the .yymps</a></p>
<p align="center">Download the <a href="https://github.com/FaultyFunctions/YarnEditor/" target="_blank">visual editor</a> by <a href="https://twitter.com/FaultyFunctions" target="_blank">Faulty</a></p>

---

Chatterbox is a GameMaker implementation of the [Yarn language](https://yarnspinner.dev/), used in games such as [Far From Noise](https://www.georgebatchelor.com/farfromnoise), [Knights and Bikes](https://foamswordgames.com/#knights), and [Night In The Woods](http://www.nightinthewoods.com/).

Yarn is designed to be accessible to writers who have little or no programming knowledge. It makes no assumptions about how your game presents dialogue to the player, or about how the player chooses their responses. Yarn has lots of [thorough documentation](https://yarnspinner.dev/docs/tutorial).

Syntax and features specific to Chatterbox [can be found here](concept-yarn-script). Chatterbox attempts to be a full implementation of the Yarn specification; if there's anything missing, please [create an Issue](https://github.com/JujuAdams/Chatterbox/issues) and Juju will do his best to meet your request.

Yarn files can be written by hand, but the best way to start with Yarn is to use an editor. The best editor to use with YarnScript v2 is [Crochet](https://github.com/FaultyFunctions/Crochet), available on [Windows, MacOS, & Ubuntu](https://github.com/FaultyFunctions/Crochet/releases), or as a [web-based editor](https://faultyfunctions.github.io/Crochet/).

## Features

-   **Powerful**<br>
    Yarn is node-based, with each node containing dialogue and options as you'd expect. But the real power to bring life to your stories is found in Yarn's [in-line commands](concept-yarn-script#actions). These can be used at any point to execute GML functions from specific points in your text, triggering cutscenes or animating faces or playing sound effects.<br>

-   **Familiarity**<br>
    Yarn looks similar to [Twine](https://twinery.org/) in many ways, but avoids the trappings of that tool. There's no [debating what version to use](https://www.reddit.com/r/twinegames/comments/eic3na/which_version_should_i_start_with/) or what particular standard is best like with Twine - Yarn has a single standard. The [visual editor](https://faultyfunctions.github.io/Crochet/) should feel comfortable for anyone who's worked in narrative design before.

-   **Tools**<br>
    Chatterbox is designed to be easy to implement and easy to make games with. [YarnScript](concept-yarn-script) can be written by hand or, more commonly, an editor is used to write your stories. There's a [web editor](https://faultyfunctions.github.io/Crochet/) as well as [Windows, MacOS, & Ubuntu](https://github.com/FaultyFunctions/Crochet/releases) binaries. Chatterbox loads in Yarn files straight from your [Included Files](https://manual.yoyogames.com/Settings/Included_Files.htm) with a [single command](reference-configuration#chatterboxloadfromfilefilename-aliasname) without any other setup.

-   **Community**<br>
    Yarn has a thriving community of narrative designers. The maintainers of Yarn run a [Slack group](http://lab.to/narrativegamedev) & [Discord server](https://discord.gg/yarnspinner), and [YarnSpinner](https://github.com/YarnSpinnerTool/) and [Crochet](https://faultyfunctions.github.io/Crochet/) (community maintained editor for Yarn v2) are constantly being updated.

?> For a full explanation of Yarn's features and syntax, please read the [YarnScript](concept-yarn-script) page.

## Updating

Releases go out once in while, typically expedited if there is a serious bug. This library uses [semantic versioning](https://semver.org/). In short, if the left-most number in the version is increased then this is a "major version increase". Major version increases introduce breaking changes and you'll almost certainly have to rewrite some code. However, if the middle or right-most number in the version is increased then you probably won't have to rewrite any code. For example, moving from `1.1.0` to `2.0.0` is a major version increase but moving from `1.1.0` to `1.2.0` isn't.

?> Please always read patch notes. Very occasionally a minor breaking change in an obscure feature may be introduced by a minor version increase.

At any rate, the process to update is as follows:

1. **Back up your whole project using source control!**
2. Back up the contents of your configuration script (`__ChatterboxConfig` or `__ChatterboxConfigMacros` depending on the version) within your project. Duplicating the script is sufficient
3. Delete all library scripts from your project. Unless you've moved things around, this means deleting the library folder from the asset browser
4. Import the latest [.yymps](https://github.com/JujuAdams/chatterbox/releases/)
5. Restore your configuration script from the back-up line by line

!> Because configuration macros might be added or removed between versions, it's important to restore your configuration script carefully.

## About & Support

If you'd like to report a bug or suggest a feature, please use the repo's [Issues page](https://github.com/JujuAdams/chatterbox/issues). Chatterbox is constantly being maintained and upgraded; bugs are usually addressed within a few days of being reported.

Chatterbox is supported for all GameMaker export modules, apart from HTML5. You might run into edge cases on platforms that I haven't tested; please [report any bugs](https://github.com/JujuAdams/chatterbox/issues) if and when you find them.

---

Chatterbox is built and maintained by [Juju Adams](https://www.jujuadams.com/) who has a long history of fiddling with text engines. Juju's worked on a lot of [commercial GameMaker games](http://www.jujuadams.com/); Chatterbox is the product of experience writing a custom narrative scripting language for [Retrace](https://store.steampowered.com/app/1052640/Retrace/) and tooling for another major GameMaker title, as yet unreleased.

Additional contributions have been made by [squircledev](https://github.com/squircledev) and [Faulty](https://github.com/FaultyFunctions). A big thank you to Els White, Jukio Kallio, rIKmAN, and squircledev for helping to test this library.

Chatterbox will never truly be finished because contributions and suggestions from new users are always welcome. Chatterbox wouldn't be the same without [your](https://tenor.com/search/whos-awesome-gifs) input! Make a suggestion on the repo's [Issues page](https://github.com/JujuAdams/chatterbox/issues) if you'd like a feature to be added.

## License

Chatterbox is licensed under the [MIT License](https://github.com/JujuAdams/Chatterbox/blob/master/LICENSE).
