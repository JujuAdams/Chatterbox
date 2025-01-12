# YarnScript

---

## Introduction

Chatterbox is an implementation of the YarnScripting language. However, Chatterbox does slightly extend its functionality, adding more control to variable handling. This enables convenient direct access of GML variables from inside the dialogue script. Please see the [Variables & Conditionals](concept-yarn-script#variables-amp-conditionals) and [Functions](concept-yarn-script#functions) sections for more information. Chatterbox additionally allows redirects and options to point to nodes found in other [source files](concept-source-files).

This document is intended to act as a comprehensive and concise reference for Yarn syntax and structure, for use by programmers and designers. It assumes a working knowledge of modern programming/scripting languages. For a more thorough explanation of Yarn usage, see the [offical Yarn tutorial](https://yarnspinner.dev/docs/tutorial).

!> Chatterbox is an implementation of version 2 of YarnScript with a few added features. When reading third-party documentation on YarnScript please make sure it is for version 2 of the language.

## Nodes

Nodes act as containers for YarnScript, and must have unique titles within each [source file](concept-source-files). The script in the body of a node is processed line by line. A node's header contains its metadata - by default, Yarn only uses the title field, but can be extended to use arbitrary fields.

```yarn
title: ExampleNodeName
tags: foo, bar
---

Yarn content goes here.
This is the second line.

===
```

A script file can contain multiple nodes. In this case, nodes are delineated using three equals (`===`) characters.
Additionally, Yarn can check if a node has been visited by calling `visited("NodeName")` in an if-statement
(i.e. `<<if visited("NodeName") == true>>`).

## Options

Options allow for small branches in YarnScripts without requiring extra nodes. Options can have any number of sub-branches, but it's recommended that branching is kept somewhat limited for the sake of script readability.

```yarn
Mae: What did you say to her?
-> Nothing.
    Mae: Oh, man. Maybe you should have.
-> That she was a jerk.
    Mae: Hah! I bet that pissed her off.
    Mae: How'd she react?
    -> She didn't.
        Mae: Booooo. That's boring.
    -> Furiously.
        Mae: That's what I like to hear!
Mae: Anyway, I'd better get going.
```

Additionally, shortcut options can utilize conditional logic, actions, and functions (detailed below), and can include standard node
links:

```yarn
Bob: What would you like?
-> A burger. <<if $money > 5>>
    Bob: Nice. Enjoy!
    <<jump AteABurger>>
-> A soda. <<if $money > 2>>
    Bob: Yum!
    <<jump DrankASoda>>
-> Nothing.
    Bob: Okay.
Bob: Thanks for coming!
```

## Random Outcomes

The option syntax above can be extended to allow for random outcomes by using the `<<random option>>` action.

```yarn
The hedge rustle besides you.
-> Investigate
You peer into the hedge and ...
<<random option>>
->
    Out hops a rabbit!
->
    A cat tumbles through a gap in the branches!
->
    A bird cheeps at you, irritated by your nosiness!
```

Options that follow a `<<random option>>` action are never presented to the player (and don't need any option text) and instead are chosen at random by Chatterbox. Options can be weighted by percentage by using metadata. Any option that doesn't have a percentage weight will "split the difference" between the accumulated percentage and 100%.

```yarn
Letting forth a discrete drunken burp, you put all your chips on lucky red number 1 and let the roulette wheel spin. You cross your fingers in your pocket, hoping no one will notice your anxiety.
<<random option>>
-> #45%
    Oooh, the ball lands on black ... better luck next time.
    If you had any money there'd be a next time anyway.
-> #40%
    Your eyes fuzz over for a second. By the time you regain your composure your chips have been shuffled away.
    What number did it land on? You can't recall, but it wasn't red number 1.
-> //Implicitly a 14% chance
    As you're focusing on your life-changing bet, Daniel stumbles into you and spills his pina colada all down your trousers.
    To make things worse, the wheel isn't kind either and you lose your bet. Dammit Daniel!
-> #1%
    It ... lands on lucky red number 1! Incredible!
    <<add_coins(1000)>>
```

Randomly chosen options also respect if-statements. Any option that is set to be randomly chosen and fails the if-statement check cannot be selected.

```yarn
<<random option>>
-> <<if inventory_has("carrot")>>
    Out hops a rabbit!
-> <<if inventory_has("tuna")>>
    A cat tumbles through a gap in the branches!
-> <<if inventory_has("seeds")>>
    A bird cheeps at you, irritated by your nosiness!
->
    Nothing but the wind ...
```

In the above example, if the player has obtained all three items then they have an equal chance of each of the four outcomes happening.

## Links Between Nodes

Moving between nodes can be done using a `<<jump>>` action (other action are available, see below):

```yarn
After this text is shown, we'll move to another node.
<<jump DestinationNode>>
```

Jump actions can be placed after options which allows for branching dialogue organised across multiple nodes.

```yarn
-> This is a link to a node.
<<jump DestinationNode>>
-> This is a link to a different node.
<<jump DifferentNode>>
```

Occasionally you might want to jump back to the top of the previously visited node. The `<<jumpback>>` action does exactly this. If there is no previous node, `<<jumpback>>` will do nothing.

?> `jumpback` doesn't use a stack and will literally jump back to previous node. This means calling `<<jumpback>>` multiple times in a row will bounce between two nodes.

Chatterbox adds the ability to target nodes in other files too:

```yarn
-> A link to a node in another file.
   <<jump TheOtherFile.json:DestinationNode>>
```

The name of the file (with that file's extension!) comes first, followed by a colon (`:`), followed by the name of the node.

?> **Please note:** Referencing nodes in other [source files](concept-source-files) is not officially supported by Yarn and this feature is an addition unique to Chatterbox.

You can also opt to "hop" out of a node to some other destination node. A hop is a reversible jump; you can hop back from your destination node back to your origin node at exactly the place you hopped out. You can call `<<hopback>>` to return to the node you came from. You can hop back and forth as much as you want. If you call `<<hopback>>` without any node to hop to then Chatterbox will instead interpret that command as a `<<stop>>`.

<!-- tabs:start -->

#### Origin

```yarn
I wonder what I should have for breakfast.
-> We have something tasty in the fridge I think?
    <<hop BreakfastNode>>
-> I don't have time for this!
Time to start my day.
```

#### Destination

```yarn
-> Pineapple juice
    Refreshing!
-> Ham and cheese
    Sustaining!
-> Fresh milk
    Creamy!
<<hopback>>
```

<!-- tabs:end -->

Hopping to a node counts as visiting a node for the purposes of the `visited()` function. If a node doesn't have `<<stop>>` or `<<hopback>>` at the end and Chatterbox reaches the very bottom of a node then it'll assume that you want to call `<<hopback>>` (and if there're no nodes to hop back to then this will stop execution). You can change this behaviour by changing the value of the config macro `CHATTERBOX_END_OF_NODE_HOPBACK`.

!> Hops are not serialized by Chatterbox. If you save in the middle of a hop you might find that the game is in an invalid state and the player cannot continue playing. Use hops carefully!

## Actions

Chatterbox has the following native actions:

```yarn
<<if "expression">>
<<else>>
<<elseif "expression">>
<<endif>>
<<set "expression">>
<<stop>>
<<wait>>
<<random option>>
<<forcewait>>
<<fastforward>>
<<fastmark>>
```

Custom actions can be added to Chatterbox by using the [`ChatterboxAddFunction()`](reference-configuration#chatterboxaddfunctionname-function) script. Custom actions should be added before
calling [`ChatterboxCreate()`](reference-chatterboxes#chatterboxcreatefilename-singletontext-localscope).

<!-- tabs:start -->

#### **GML**

```gml
ChatterboxLoad("example.json");
ChatterboxAddFunction("playMusic", play_background_music);
```

#### **YarnScript**

```yarn
Here's some text!
<<playMusic>>
The music will have started now.
```

<!-- tabs:end -->

By adding the custom action `playMusic` and binding it to the script `play_background_music()`, Chatterbox will now call this script
whenever `<<playMusic>>` is processed by Chatterbox.

Custom actions can also have parameters. These parameters can be any Chatterbox value - a real number, a string, or a variable.
Parameters should separated by spaces. Parameters are passed into a script as an array of values in argument0.

<!-- tabs:start -->

#### **GML**

```gml
ChatterboxLoad("example.json");
ChatterboxAddFunction("gotoRoom", go_to_room);
```

#### **YarnScript**

```yarn
Let's go see what the priest is up to.
<<gotoRoom "rChapel" $entrance>>
<<stop>>
```

<!-- tabs:end -->

Chatterbox will execute the script `go_to_room()` whenever `<<gotoRoom>>` is processed. In this case, `go_to_room()` will receive an array
of two values from Chatterbox. The first (index 0) element of the array will be `"rChapel"` and the second (index 1) element will
hold whatever value is in the `$entrance` variable.

## Variables & Conditionals

Declaring and Setting Variables:
This statement serves to set a variable's value. No declarative statement is required; setting a variable's value brings it into existence.

```yarn
<<set $ExampleVariable to 1>>
```

All variables must start with a dollar sign. Internal Yarn variables are, in reality, key:value pairs stored in a global ds_map. Chatterbox has [a handful of functions](reference-variables) dedicated to handling variables, including importing and exporting them.

If needed, you can access this ds_map via the `CHATTERBOX_VARIABLES_MAP` macro, found in [`__ChatterboxConfig()`](reference-configuration#__chatterboxconfig).

### String Interpolation

You may be familiar with string interpolation in native GML where the syntax `$"Some text, {aVariableToInsert}, some more text"` can be used to insert a value from a variable into a string. YarnScript has a similar feature and its syntax is very close. Variables can be inserted into string by wrapping a variable name in curly brackets. Variables can contain any type of data, strings or numbers. In fact, any YarnScript expression can be put inside curly brackets to insert the value returned by the expression into a string.

```yarn
Clive: How many bottles of beer are there on the wall?
Claire: {$bottlesOfBeer} bottles of beer.
Clive: {$bottlesOfBeer}?
Claire: Yes, there are {$bottlesOfBeer-1} on the wall.
Claire: Hold on, did you just drink a bottle?
Clive: ... no.
```

### if/else Statements: <!-- {docsify-ignore} -->

Yarn supports standard if/else/elseif statements.

```chatterscript
<<if "hi" == "hi">>
    The two strings are the same!
<<endif>>
```

Every `<<if>>` branch must be followed by an associated `<<endif>>`. You can also use `<<else>>` and `<<elseif>>` to create more complex multiple choice branches.

```
<<if $variable == 1>>
    Success!
<<elseif $variable == "hello">>
    Success...?
<<else>>
    No success. :(
<<endif>>
```

### Expressions: <!-- {docsify-ignore} -->

There are four different types of variable in Yarn: strings, floating-point numbers, booleans, and null.

Yarn will automatically convert between types. For example:

```yarn
<<if "hi" == "hi">>
    The two strings are the same!
<<endif>>

<<if 1+1+"hi" == "2hi">>
    Strings get joined together with other values!
<<endif>>
```

## Functions

By default, Chatterbox includes a `visited()` function which returns the number of times a node has been entered.

```yarn
<<if visited("GoToCity")>>
    We have gone to the city before!
<<endif>>
```

Chatterbox also includes the `optionChosen()` function. This works similarly to `visited()` but can only be used in the condition for an option, like so:

```yarn
How can I help?
-> Can I buy some green eggs please? <<if !optionChosen()>>
    No... This is a stationery shop.
-> Do you have any ham for sale? <<if !optionChosen()>>
    Huh? We mostly sell birthday cards.
```

Using `optionChosen()` outside of an option condition is invalid and will throw an error. What options have been chosen is not intended to persist between gameplay sessions and is not included in the data returned by `ChatterboxVariablesExport()`. If you want to track which options have been chosen, you will instead need to write your own system.

Other custom functions can be added to Chatterbox using the [`ChatterboxAddFunction()`](reference-configuration#chatterboxaddfunctionname-function) script. Much like custom actions, custom functions can have parameters. Custom functions should be defined before calling [`ChatterboxCreate()`](reference-chatterboxes#chatterboxcreatefilename-singletontext-localscope).

<!-- tabs:start -->

#### **GML**

```gml
ChatterboxLoad("example.json");
ChatterboxAddFunction("AmIDead", am_i_dead);
```

#### **YarnScript**

```yarn
Am I dead?
<<if AmIDead("player")>>
    Yup. Definitely dead.
<<else>>
    No, not yet!
<<endif>>
```

<!-- tabs:end -->

This example shows how the script `am_i_dead()` is called by Chatterbox in an if statement. The value returned from `am_i_dead()` determines which text is displayed.

&nbsp;

Here's a list of supported operators (in no particular order) that are supported in expressions:

|     Word     | Symbol | Use                                    |
| :----------: | :----: | -------------------------------------- |
|    `not`     |  `!`   | Logical negation                       |
|              |  `+`   | Real addition, or string concatenation |
|              |  `-`   | Real substraction, or negative         |
|              |  `*`   | Real multiplication                    |
|              |  `/`   | Real division                          |
| _Assignment_ |        |                                        |
|     `to`     |  `=`   | Assignment                             |
|              |  `+=`  | Add or concatenate, then assign        |
|              |  `-=`  | Subtract, then assign                  |
|              |  `*=`  | Multiply, then assign                  |
|              |  `/=`  | Divide, then assign                    |
| _Comparison_ |        |                                        |
|    `and`     |  `&&`  | Logical AND                            |
|     `le`     |  `<`   | Less than                              |
|     `gt`     |  `>`   | Greater than                           |
|     `or`     | `\|\|` | Logical OR                             |
|    `leq`     |  `<=`  | Less-than-or-equal-to                  |
|    `geq`     |  `>=`  | Greater-than-or-equal-to               |
|    `lte`     |  `<=`  | Less-than-or-equal-to                  |
|    `gte`     |  `>=`  | Greater-than-or-equal-to               |
|     `eq`     |  `==`  | Equal to                               |
|     `is`     |  `==`  | Equal to                               |
|    `neq`     |  `!=`  | Not equal to                           |

## Fast-Forwarding

Chatterbox allows you to, at will, fast-forward past content strings. This is handy for games with a ton of content, or with a lot of replayability value as it allows players to skip past things they've seen before. Fast-forwarding will speed allow, skipping content strings, until hitting one of the following:

1. The end of a Chatterbox or `<<stop>>`

2. An option `->`

3. A `<<forcewait>>` action

Fast-forwarding is typically triggered by calling `ChatterboxFastForward()` but you may also find it useful to trigger a fast-forward from YarnScript. You can do this using `<<fastforward>>` in YarnScript as you would other actions.

You can also turn fast-forwarding off from inside YarnScript as well; this is done with the `<<fastmark>>` action. Content **after** `<<fastmark>>` will still appear but any content between triggering fast-forwarding and `<<fastmark>>` will not appear.
