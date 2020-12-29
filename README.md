<p align="center"><img src="https://raw.githubusercontent.com/JujuAdams/Chatterbox/master/LOGO.png" style="display:block; margin:auto; width:170px"></p>
<h1 align="center">1.0.0</h1>

<p align="center">Narrative engine for GameMaker Studio 2.3.0 by <b>@jujuadams</b></p>

<p align="center"><a href="https://github.com/JujuAdams/chatterbox/releases/">Download the .yymps</a></p>
<p align="center">Talk about Chatterbox on the <a href="https://discord.gg/8krYCqr">Discord server</a></p>

*A big thank you to Els White, Jukio Kallio, rIKmAN, and Sean Oxspring for helping to test and develop this library.*

&nbsp;

Chatterbox is a GameMaker implementation of the [Yarn language](https://yarnspinner.dev/), used in games such as [Far From Noise](https://www.georgebatchelor.com/farfromnoise), [Knights and Bikes](https://foamswordgames.com/#knights), and [Night In The Woods](http://www.nightinthewoods.com/).

Yarn is designed to be accessible to writers who have little or no programming knowledge. It makes no assumptions about how your game presents dialogue to the player, or about how the player chooses their responses. Yarn has lots of [thorough documentation](https://yarnspinner.dev/docs/tutorial).

Syntax and features specific to Chatterbox [can be found here](https://raw.githubusercontent.com/JujuAdams/Chatterbox/master/notes/__chatterbox_syntax/__chatterbox_syntax.txt). Chatterbox attempts to be a full implementation of the Yarn specification; if there's anything missing, please [create an Issue](https://github.com/JujuAdams/Chatterbox/issues) and Juju will do his best to meet your request.

Yarn files can be written by hand, but the best way to start with Yarn is to use an editor. The standard Yarn Editor tool is available on [Windows and MacOS](https://github.com/YarnSpinnerTool/YarnEditor/releases/), or as a [web-based editor](https://yarnspinnertool.github.io/YarnEditor/).

&nbsp;

**How do I import Chatterbox into my game?**

GameMaker Studio 2.3.0 allows you to import assets, including scripts and shaders, directly into your project via the "Local Package" system. From the [Releases](https://github.com/JujuAdams/chatterbox/releases/) tab for this repo, download the .yymps file for the latest version. In the GMS2 IDE, load up your project and click on "Tools" on the main window toolbar. Select "Import Local Package" from the drop-down menu then import all scripts from the package.
