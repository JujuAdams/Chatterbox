# Yarn Script

---

?> This is an edited copy of the [YarnSpinner Quick Refence Guide](https://github.com/thesecretlab/YarnSpinner/blob/master/Documentation/YarnSpinner-Dialogue/Yarn-Syntax.md) (retrieved 2019-04-18)

## Introduction

Chatterbox is an implementation of the Yarn scripting language. However, Chatterbox does slightly extend its functionality,
adding more control to variable handling. This enables convenient direct access of GML variables from inside the dialogue script.
Please see the [Variables & Conditionals](concept-yarn-script#variables-amp-conditionals) and [Functions](concept-yarn-script#functions) sections for more information. Chatterbox additionally allows redirects and options to
point to nodes found in other [source files](concept-source-files).

This document is intended to act as a comprehensive and concise reference for Yarn syntax and structure, for use by programmers
and designers. It assumes a working knowledge of modern programming/scripting languages. For a more thorough explanation
of Yarn usage, see the [offical Yarn tutorial](https://yarnspinner.dev/docs/tutorial).

!> **Note**: As of 29/07/2021, the official Yarn tutorials show syntax from version 1 of Yarn, while Chatterbox v2 implements the updated version 2 of the Yarn specification. The syntax listed here is the most up to date for what Chatterbox v2 uses.

## Nodes

Nodes act as containers for Yarn script, and must have unique titles within each [source file](concept-source-files). The script in the body of a node is processed line by line. A node's header contains its metadata - by default, Yarn only uses the title field, but can be extended to use arbitrary fields.

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

Options allow for small branches in Yarn scripts without requiring extra nodes. Options can have any number of sub-branches, but it's recommended that branching is kept somewhat limited for the sake of script readability.

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

Chatterbox adds the ability to target nodes in other files:

```yarn
-> A link to a node in another file.
   <<jump TheOtherFile.json:DestinationNode>>
```

The name of the file (with that file's extension!) comes first, followed by a colon (`:`), followed by the name of the node.

?> **Please note:** Referencing nodes in other [source files](concept-source-files) is not officially supported by Yarn and this feature is an addition unique to Chatterbox.

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
```

Custom actions can be added to Chatterbox by using the [`ChatterboxAddFunction()`](reference-configuration#chatterboxaddfunctionname-function) script. Custom actions should be added before
calling [`ChatterboxCreate()`](reference-chatterboxes#chatterboxcreatefilename-singletontext-localscope).

<!-- tabs:start -->

#### **In GameMaker**

```gml
ChatterboxLoad("example.json");
ChatterboxAddFunction("playMusic", play_background_music);
```

#### **In Yarn**

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

#### **In GameMaker**

```gml
ChatterboxLoad("example.json");
ChatterboxAddFunction("gotoRoom", go_to_room);
```

#### **In Yarn**

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

### If/Else Statements: <!-- {docsify-ignore} -->

Yarn supports standard if/else/elseif statements.

```yarn
<<if "hi" == "hi">>
    The two strings are the same!
<<endif>>
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

By default, Chatterbox includes a `visited()` function, used to check whether a node has been entered.

```yarn
<<if visited("GoToCity")>>
    We have gone to the city before!
<<endif>>
```

Other custom functions can be added to Chatterbox using the [`ChatterboxAddFunction()`](reference-configuration#chatterboxaddfunctionname-function) script. Much like custom actions, custom functions can have parameters. Custom functions should be defined before calling [`ChatterboxCreate()`](reference-chatterboxes#chatterboxcreatefilename-singletontext-localscope).

Parameters should be separated by spaces and are passed into a script as an array of values in `argument0`.
Custom functions can return values, but they should be reals or strings.

<!-- tabs:start -->

#### **In GameMaker**

```gml
ChatterboxLoad("example.json");
ChatterboxAddFunction("AmIDead", am_i_dead);
```

#### **In Yarn**

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
|     `eq`     |  `==`  | Equal to                               |
|     `is`     |  `==`  | Equal to                               |
|    `neq`     |  `!=`  | Not equal to                           |
