# Getting Started

The Chatterbox library is built around little digital machines, called chatterboxes, that interpret narrative instructions stored in external files using a language called YarnScript. A chatterbox processes YarnScript and spits out text (called **content**) and sometimes a list of **options**. You can control these chatterbox machines by calling ["flow control" functions](reference-flow) using GML from your game, and this is how you communicate player decisions to chatterboxes.

Chatterbox itself does little more than hand you lines of text that you can draw to the screen, but you are entirely responsible for determining how to draw that text. Equally, chatterboxes do no processing unless you specifically call a function to tell them to do something. Chatterbox execution is "synchronous" - when you tell a chatterbox to do something, it'll do it immediately. You can build functionality to make some behaviour asynchronous if you'd like but that is not a native feature.

Chatterbox offers a lot of ways to [configure](reference-configuration) the way it works so that it can adapt to varied use cases, and has many functions available to otherwise interact with YarnScript data. This guide is intended to demonstrate basic usage for simple visual novel-style dialogue delivery which is generally applicable across most games.

&nbsp;

## YarnScript

As mentioned, chatterboxes read instructions written in a language called YarnScript. You can find more information about YarnScript in [here](concept-yarn-script) in Chatterbox's documentation. Whilst it's possible to write YarnScript by hand in a text file, we recommend that you use the free [Crochet](https://github.com/FaultyFunctions/Crochet) editor developed by [FaultyFunctions](https://twitter.com/faultyfunctions/). Crochet removes a lot of the organisational hurdles and gets you straight to writing your script.

Before we get stuck into writing YarnScript, a few words on structure: YarnScript files are made out of nodes, and nodes contain lines of instructions. Crochet allows you to visually edit and organise nodes. Every node in a YarnScript file has a unique name, and node names cannot contain spaces. You can also attach metadata to nodes should you wish, though we won't cover that in this particular guide. YarnScript files themselves are "just text files" and you can edit them by hand if needed.

YarnScript is a procedural language just like GML. Instructions start at the top of a node and are executed from top to bottom, one at a time. Let's presume we've got Chatterbox set up for operation in "singleton mode" where each line of dialogue is delivered one-by-one, like any number of visual novels or RPGs. If we write out the following YarnScript in a node like so:

```yarn
This is the first line.
A second line.
And, finally, a third line.
```

...then what we'll get in Chatterbox is three separate lines of text in the order that we wrote them. Straightforward lines of text to be displayed to the player are called **content**. Lines of dialogue typically comprise the majority of a node. We'll discuss later how to actually read **content** strings in GML, but for now let's talk a bit more about YarnScript.

YarnScript also supports **options**. Options come in blocks and you can have any number of options in a block which means you can have a single-choice option block if you'd like. Options work similarly to a line of dialogue but have a `->` little arrow at the start of the line.

```yarn
Where would you like to go today?
-> To the shops.
-> To outer space.
Very well! Let's go.
```

You can choose to show dialogue after an option too. Dialogue that is indented and placed immediately following an option will only be shown if the player chooses that option and that option alone. In the following example, an appropriate response is scripted to appear after the player chooses an option. Note that the final line of dialogue will be shown regardless of which option the player chose.

```yarn
Where would you like to go today?
-> To the shops.
    Yes, I'm hungry too.
-> To outer space.
    Have you packed your spacesuit?
Very well! Let's go.
```

You can also nest options, again using indentation to indicate the structure of the branching dialogue.

```yarn
Where would you like to go today?
-> To the shops.
    Yes, I'm hungry too.
-> To outer space.
    Have you packed your spacesuit?
	-> No...
	    We'll have to swing by the shops then.
	-> Sure have!
Very well! Let's go.
```

One last thing before we talk about the GML-side implementation of Chatterbox - actions. Actions are neither **content** nor **options** and represent either flow control for the YarnScript, or a way to execute code that can affect the rest of your game. You'll always see actions written in `<<` angle brackets `>>`. For example:

```yarn
Where would you like to go today?
-> To the shops.
    Yes, I'm hungry too.
	<<set $nextNode = "Shops">>
-> To outer space.
    Have you packed your spacesuit?
	-> No...
	    We'll have to swing by the shops then.
		<<set $nextNode = "Shops">>
	-> Sure have!
	    <<set $nextNode = "OuterSpace">>
Very well! Let's go.
<<jump $nextNode>>
```

This example demonstrates a couple of more advanced concepts - the `<<set>>` action which is used to set the value of Chatterbox variables, and the `<<jump>>` action which is used to navigate between nodes. We'll go into depth for these two actions (they're very useful) a little later. For now, we'll stick to **content** and **options**.

&nbsp;

## GML Implementation

Chatterbox requires a little setup inside GameMaker before you can start interacting with your YarnScript. There are a few steps to start things up, and we'll go through them in detail, but here's an overview:

1. Import the Chatterbox .yymps into your project
2. Call `ChatterboxLoadFromFile()` to load the YarnScript source file from Included Files
3. Call `ChatterboxCreate()` to create a new chatterbox to manage YarnScript processing
4. Call various [flow control](reference-flow) functions to navigate your dialogue
5. Extract [content](reference-content-getters) and [option](reference-option-getters) strings from the chatterbox

### Importing Chatterbox

Chatterbox is distributed as a .yymps file. This is a compressed file (literally a .zip!) that contains all the GML code that Chatterbox needs to run. You can find the latest release [here](https://github.com/JujuAdams/Chatterbox/releases) and it can be imported via the `Tools` dropdown menu then `Import Local Pakage`. Generally, you'll want to be on the latest stable version. You can always check what version you're using by checking the debug log - Chatterbox outputs its version on boot - or by reading the value of the `__CHATTERBOX_VERSION` macro. Make sure to import all the assets in the .yymps!

### Loading your YarnScript source file

Before you can create a chatterbox you'll need to load in a YarnScript file. Make sure you've added a source file to GameMaker as an "Included File" by saving it to the `\datafiles` directory in your project files. Loading that file is then as simple as calling `ChatterboxLoadFromFile()` targeting that specific filename: 

```gml
/// Create event for an object
ChatterboxLoadFromFile("example.yarn");
```

?> The first file that you load becomes the "default" source file for Chatterbox.

!> Chatterbox parses and compiles YarnScript files when loaded for better performance later; as a result, you may find that there's a short hang when loading large YarnScript files. You should try to load YarnScript files during a loading screen to minimise disruption to the user experience.

### Initializing a chatterbox

Now that a YarnScript source file has been loaded, we can spin up a chatterbox and start navigating dialogue. Here's how:

```gml
/// Create event for an object
ChatterboxLoadFromFile("example.yarn");
chatterbox = ChatterboxCreate();
ChatterboxJump(chatterbox, "StartNode");
```

It's very important to hold a reference to the chatterbox that gets created by `ChatterboxCreate()` as you'll need it for all other API functions. In this case, because we've only loaded one source file, we don't need to specify a file for `ChatterboxCreate()`. If you load more than one file you'll need to tell `ChatterboxCreate()` which file to start reading from. `ChatterboxCreate()` can be further customised by setting values for its optional arguments, and you can read more about what those do [here](reference-chatterboxes).

### Flow control

&nbsp;

### Drawing chatterbox text

&nbsp;

## Further YarnScript features