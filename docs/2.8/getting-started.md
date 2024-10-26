# Getting Started

The Chatterbox library is built around little digital machines, called chatterboxes, that interpret narrative instructions stored in external files using a language called YarnScript. A chatterbox processes YarnScript and spits out text (called **content**) and sometimes a list of **options**. You can control these chatterbox machines by calling ["flow control" functions](reference-flow) using GML from your game, and this is how you communicate player decisions to chatterboxes.

Chatterbox itself does little more than hand you lines of text that you can draw to the screen, but you are entirely responsible for determining how to draw that text. Equally, chatterboxes do no processing unless you specifically call a function to tell them to do something. Chatterbox execution is "synchronous" - when you tell a chatterbox to do something, it'll do it immediately. You can build functionality to make some behaviour asynchronous if you'd like but that is not a native feature.

Chatterbox offers a lot of ways to [configure](reference-configuration) the way it works so that it can adapt to varied use cases, and has many functions available to otherwise interact with YarnScript data. This guide is intended to demonstrate basic usage for simple visual novel-style dialogue delivery which is generally applicable across most games.

&nbsp;

## YarnScript

As mentioned, chatterboxes read instructions written in a language called YarnScript. You can find detailed information about Chatterbox's implementation of YarnScript [here](concept-yarn-script). YarnScript files are made out of nodes, and nodes contain lines of instructions. Every node in a YarnScript file has a unique name, and node names cannot contain spaces. You can also attach metadata to nodes should you wish, though we won't cover that in this particular guide. Beyond requiring a certain structure, YarnScript files themselves are "just text files" and you can edit them by hand if needed.

?> We recommend that you use the free visual edtior [Crochet](https://github.com/FaultyFunctions/Crochet) developed by [FaultyFunctions](https://twitter.com/faultyfunctions/). Crochet removes a lot of the organisational hurdles of writing YarnScript and gets you straight to writing dialogue.

YarnScript is a procedural language just like GML. Instructions start at the top of a node and are executed from top to bottom, one at a time. Let's presume we've got Chatterbox set up for operation in "singleton mode" where each line of dialogue is delivered one-by-one, like any number of visual novels or RPGs. If we write out the following YarnScript in a node like so:

```yarn
This is the first line.
A second line.
And, finally, a third line.
```

...then what we'll get in Chatterbox is three separate lines of text in the order that we wrote them. Straightforward lines of text to be displayed to the player are called **content**. Lines of dialogue typically comprise the majority of a node. We'll discuss later how to actually read **content** strings in GML.

!> Once chatterbox reaches the end of a node it puts the chatterbox into a stopped state. If you want a node to flow into another node automatically you should use the `<<jump>>` action, explained a little later in this guide.

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

This example demonstrates a couple of more advanced concepts - the `<<set>>` action which is used to set the value of Chatterbox variables, and the `<<jump>>` action which is used to navigate between nodes. We'll go into depth for these two actions (they're very useful) further on.

&nbsp;

## GML Implementation

Chatterbox requires a little setup inside GameMaker before you can start interacting with your YarnScript. There are a few steps to start things up, and we'll go through them in detail, but here's an overview:

1. Import the Chatterbox .yymps into your project
2. Call `ChatterboxLoadFromFile()` to load the YarnScript source file from Included Files
3. Call `ChatterboxCreate()` to create a new chatterbox to manage YarnScript processing
4. Call various [flow control](reference-flow) functions to navigate your dialogue
5. Extract [content](reference-content-getters) and [option](reference-option-getters) strings from the chatterbox

### 1. Importing Chatterbox

Chatterbox is distributed as a .yymps file. This is a compressed file (literally a .zip!) that contains all the GML code that Chatterbox needs to run. You can find the latest release [here](https://github.com/JujuAdams/Chatterbox/releases) and it can be imported via the `Tools` dropdown menu then `Import Local Pakage`. Generally, you'll want to be on the latest stable version. You can always check what version you're using by checking the debug log - Chatterbox outputs its version on boot - or by reading the value of the `__CHATTERBOX_VERSION` macro. Make sure to import all the assets in the .yymps!

### 2. Loading your YarnScript source file

Before you can create a chatterbox you'll need to load in a YarnScript file. Make sure you've added a source file to GameMaker as an "Included File" by saving it to the `\datafiles` directory in your project files. Loading that file is then as simple as calling `ChatterboxLoadFromFile()` targeting that specific filename: 

```gml
/// Create event for an object
ChatterboxLoadFromFile("example.yarn");
```

Once a source file has been loaded it can be accessed from anywhere by a chatterbox. You will encounter errors if a source file has not been loaded and you try to use it so be careful how you structure your YarnScript.

?> The first file that you load becomes the "default" source file for Chatterbox.

!> Chatterbox parses and compiles YarnScript files when loaded for better performance later; as a result, you may find that there's a short hang when loading large YarnScript files. You should try to load YarnScript files during a loading screen to minimise disruption to the user experience.

### 3. Initializing a chatterbox

Now that a YarnScript source file has been loaded, we can spin up a chatterbox and start navigating dialogue. Here's how:

```gml
/// Create event for an object
ChatterboxLoadFromFile("example.yarn");
chatterbox = ChatterboxCreate();
ChatterboxJump(chatterbox, "StartNode");
```

It's very important to hold a reference to the chatterbox that gets created by `ChatterboxCreate()` as you'll need it for all other API functions. In this case, because we've only loaded one source file, we don't need to specify a file for `ChatterboxCreate()`. If you load more than one file you'll need to tell `ChatterboxCreate()` which file to start reading from. `ChatterboxCreate()` can be further customised by setting values for its optional arguments, and you can read more about what those do [here](reference-chatterboxes).

### 4. Flow control

Flow control functions are the way that you as a developer control how Chatterbox moves around inside a YarnScript file. You can see a full list of flow control functions [here](reference-flow).

`ChatterboxJump()`, used above in the GML example, is one of these "flow control" functions, and is analogous to the `<<jump>>` action that's available for use in YarnScript itself. Whenever either the GML function or the YarnScript action are called, a chatterbox will jump to the specified node and start processing instruction from the top of that node.

In singleton mode, the default processing mode for Chatterbox, each line of content is delivered one at a time. This means that after processing each line of dialogue (and if there are no options that come after that line of dialogue) a chatterbox will enter a "waiting" state. You can detect when a chatterbox is waiting by using the `ChatterboxIsWaiting()` function. In order to get a chatterbox to proceed onto the next line of dialogue, you must call the `ChatterboxContinue()` function.

?> If you are not in singleton mode, you can force a chatterbox to wait at a particular line by using the `<<wait>>` action in YarnScript.

As just mentioned, a chatterbox **won't** enter into a "waiting" state if there are any options that might need to be selected. If a chatterbox is waiting for an option to be selected, `ChatterboxContinue()` will do nothing. Instead, you should call `ChatterboxSelect()` to indicate which option the player has chosen. You can check how many options are being presented to the player with the `ChatterboxGetOptionCount()` function. This function will return `0` if no option are present, and any number greater than `0` indicates that the chatterbox is waiting for user input.

Finally, you can completely stop processing in a chatterbox using `ChatterboxStop()`, which is also analogous to the `<<stop>>` command that can be used in YarnScript itself. A stopped chatterbox will return no content nor options. If a chatterbox reaches the end of a node and there are no more instructions to run, it'll enter into this "stopped" state. You can check if a chatterbox has stopped using the `ChatterboxIsStopped()` GML function. You can use `ChatterboxJump()` to restart a chatterbox if stopped, should you wish to.

Here's an example of how to set up very simple user input, taken from the basic example in the GitHub repo.

```gml
if (ChatterboxIsStopped(chatterbox))
{
    //If we're stopped then don't respond to user input
}
else if (ChatterboxIsWaiting(chatterbox))
{
    //If we're in a "waiting" state then let the user press <space> to advance dialogue
    if (keyboard_check_released(vk_space))
    {
        ChatterboxContinue(chatterbox);
    }
}
else
{
    //If we're not waiting then we have some options!
    //Check for any keyboard input
    var _index = undefined;
    if (keyboard_check_released(ord("1"))) _index = 0;
    if (keyboard_check_released(ord("2"))) _index = 1;
    if (keyboard_check_released(ord("3"))) _index = 2;
    if (keyboard_check_released(ord("4"))) _index = 3;
    
    //If we've pressed a button, select that option
    if (_index != undefined) ChatterboxSelect(chatterbox, _index);
}
```

### 5. Drawing chatterbox text

Chatterbox is, ultimately, a string delivery device with some clever logic attached to it. You are responsible for marshalling, queuing, and displaying text that Chatterbox returns. To this end, the output functions that are available in Chatterbox are very simple. They're split into two kinds: **content** and **options**.

Content is plain text that is intended to be displayed to the player for them to read. You might want to come up with your own text formatting system or a particular syntax for controlling the details of text rendering, but to Chatterbox, all content is plain text. In singleton mode, the default setting for Chatterbox, you should only receive one content string at a time which correlates to each individiual line of text in a YarnScript node. Regardless, you can find the number of content strings that a chatterbox is handing over to you by using `ChatterboxGetContentCount()` and you can read each individual piece of content using `ChatterboxGetContent()`.

?> In non-singleton mode, you may receive many content strings at a time. Each line of text will be returned as a separate content string. If you're intending on displaying multiple lines of text using newlines, you may want to consider using `ChatterboxGetAllContentString()` to return a block of text.

Similarly, options are also plain text. You can get the total number of options using `ChatterboxGetOptionCount()` and the text for each individual option with `ChatterboxGetOption()`. Options strings may be returned by a chatterbox at the same time as content strings depending on the layout of your YarnScript. Please read the previous section for more details.

Exactly how and where you present content and options is up to you. Radial menu? Scrollable list? Roulette wheel? The choice is yours. Here's a very basic example of how to display content and options together taken from the basic example in the GitHub repo:

```gml
var _x = 10;
var _y = 10;

if (ChatterboxIsStopped(chatterbox))
{
    //If we're stopped then show that
    draw_text(_x, _y, "(Chatterbox stopped)");
}
else
{
	//Draw all content
    var _i = 0;
    repeat(ChatterboxGetContentCount(chatterbox))
    {
        var _string = ChatterboxGetContent(chatterbox, _i);
        draw_text(_x, _y, _string);
        _y += string_height(_string);
        ++_i;
    }
    
    _y += 30; //Bit of spacing...

    if (ChatterboxIsWaiting(chatterbox))
    {
        //If we're in a "waiting" state then prompt the user for basic input
        draw_text(_x, _y, "(Press Space)");
    }
    else
    {
    	//Draw all options
        var _i = 0;
        repeat(ChatterboxGetOptionCount(chatterbox))
        {
            var _string = ChatterboxGetOption(chatterbox, _i);
            draw_text(_x, _y, string(_i+1) + ") " + _string);
            _y += string_height(_string);
            ++_i;
        }
    }
}
```

&nbsp;

## Further YarnScript features

YarnScript is considerably more complex than showing content and options and navigating through branching dialogue. YarnScript offers you variables, conditional logic, metadata, string insertion and [so much more](concept-yarn-script). I'd like to highlight a couple key features here, ones that are uniquely helpful when writing interactive storylines for your game.

Firstly, the `<<jump>>` action allows you to move between nodes in a YarnScript source file. The syntax for this action is `<<jump NameOfNode>>`. You can also jump to a node whose name is stored in a variable (and we saw an example of this earlier) by simply inserting the variable into the action, like so: `<<jump $nodeVariable>>` where `$nodeVariable` is the variable that holds the name of the node to jump to.

There's more, however! `<<jump>>` can also allow you to jump to a node in a _different_ source file entirely. You must have previously loaded the source file into memory using `ChatterboxLoadFromFile()`, and you can jump to a node into another file using this syntax: `<<jump filename.yarn:NameOfNode>>`. If you want to jump to node outside the current source file then you **must** specify the filename.

?> Remember, node names must be unique _within_ a YarnScript file. Node names are allowed to collide _between_ source files. This is useful for templating character interactions.

The other powerful feature I'd like to talk about is **Chatterbox variables**. These will be familiar to you if you've done really any work with GML. Chatterbox variables have a few special rules, however, and are a little stricter than their GML counterparts.

1. Chatterbox variables must be prefixed with `$` in YarnScript.
2. Chatterbox variables are globally scoped. You can access them at any point anywhere in YarnScript (`$variableName`) and GML (`ChatterboxVariableGet()`)
3. Chatterbox variables are sandboxed. You can only access them using Chatterbox functions.
4. Chatterbox variables should be declared before use, either using YarnScript (`<<declare $variableName = "value">>`) or GML (`ChatterboxVariableDefault()`). Variable declarations are important because they ensure type safety and that all Chatterbox variables have legal default value.
5. Chatterbox variables must only be strings, numbers, or booleans. Complex types are not permitted.

When working with YarnScript, you can set variables using the `<<set>>` action e.g. `<<set $variableName = $variableName + 42>>`. This is already useful, but the real power with variables can be found in conditional logic - the almighty `<<if>>` action and its siblings `<<else>>` `<<elseif>>` and `<<endif>>`.

`<<if>>` is a special kind of action that performs flow control inside a node. Again, if you've written much GML, an if-statement will not be alien to you and YarnScript works in exactly the same way.

```yarn
<<if $cats == 3>>
	Five cat plan in three cats!
<<elseif $cats >= 5>>
    I think you have enough cats already.
<<else>>
	More cats might help you on your journey.
<<endif>>
```

We can also apply `<<if>>` actions to options, allowing more intelligent options to be shown to the player.

```yarn
Have you packed your spacesuit?
-> No... <<if not $spacesuit>>
    We'll have to swing by the shops then.
	<<set $nextNode = "Shops">>
-> Sure have! <<if $spacesuit>>
    <<set $nextNode = "OuterSpace">>
```

As per the YarnScript specification, all options will made available **regardless of whether the if-statement returns `true` or `false`**. This is unexpected behaviour but it does give you more control over how you communicate failed conditions e.g. showing options that are unavailable due to a low charisma stat and so on. To determine whether to display an option or not to a player you can call `ChatterboxGetOptionConditionBool()` which tells you the state of the associated condition.

Variables allow you to branch dialogue in response to a value that you're tracking, and that value will be reacting to decisions that the player has made. With a little effort, you could write an entire game in YarnScript with a very simple GameMaker program wrapped around it.

&nbsp;

## Closing thoughts

Chatterbox is a powerful tool and we've only scratched the surface. Please take the time to poke around the rest of the documentation and, if you have any questions, please swing by the [Discord server](https://discord.gg/8krYCqr).