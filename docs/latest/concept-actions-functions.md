# Actions and Functions

YarnScript allows for flow control and the execution of external code by using its "action" syntax. Actions in YarnScript are commands written in between `<<` and `>>` like so:

```yaml
title: FlowerSeedShelf
---

<<declare $flowerSeeds as 0>>
<<const $maximumFlowerSeeds as 3>>

You see upon the shelf a selection of packets of flower seeds arranged clumsily.
-> Inspect them.
    Their attractive full-colour printing is rather eye-catching. Their names are unfamiliar to you, as though the words were made of jumbled syllables.
-> Pick one at random.
    <<if $flowerSeeds >= $maximumFlowerSeeds>>
        You pick up a packet but another in your hands slips through your fingers. You're holding as many flower seeds as you can.
    <<else>>
        <<set $flowerSeeds to $flowerSeeds + 1>>
        You thrust your hand into the pile of seed packets and choose by feel... though they all feel the same to you.
    <<endif>>
-> Move down the aisle. You don't trust yourself to grow flowers anyway.
    <<jump DownTheAisle>>

//Replay this node until the player chooses to move down the aisle
<<jump FlowerSeedShelf>>
===
```

&nbsp;

Chatterbox has the following in-built actions:

### `jump`

*Example:* `<<jump TheNodeOnTheHill>>`

*Example*: `<<jump Christina.yarn:GenericGreeting>>`

*Example*: `<<jump $nodeTitleStoredInAVariable>>`

The `<<jump>>` action causes a chatterbox to immediately swap execution to another node in a YarnScript file. Execution will start from the top of the new node. If you `<<jump>>` back to the old node then you will start execution from the top of the node. You can specify a particular YarnScript file to jump to by specifying the filename first, typing a `:` colon, and then specifying the node in that file. If you don't specify a file then Chatterbox will search in the current file for the desired node. `<<jump>>` can be used to jump to a node stored in a variable by referencing the variable as the destination node title.

&nbsp;

### `hop` and `hopback`

*Example:* `<<hop WistfulMemories>>` and later `<<hopback>>`

*Example:* `<<hop TangentialConversations.yarn:NatureOfBeing>>` and later `<<hopback>>`

*Example*: `<<hop $nodeTitleStoredInAVariable>>` and later `<<hopback>>`


`<<hop>>` operates similarly to `<<jump>>` (see above). `<<hop>>` differs from `<<jump>>` insofar as you can hop back into a node from where you hopped out. This operates on a stack such that calling `<<hop>>` twice and then calling `<<hopback>>` twice will result in a chatterbox being at the exact same position that the first `<<hop>>` was called.

!> It is not possible to save or load the hop stack. Do not rely on the hop stack for tracking important game logic that may need to persist between game sessions.

&nbsp;

### `declare`

*Example:* `<<declare $favouriteFood = "Cheesecake">>`

*Example:* `<<declare $favouriteFood as "Cheesecake">>`

This action instructs Chatterbox to declare a variable and to give it a default value.

&nbsp;

### `set`

*Example:* `<<set $favouriteFood = "Curry">>`
    
*Example:* `<<set $favouriteFood as "Curry">>`

Sets the value of a variable, plain and simple. The datatype of a variable (string, number, or boolean `true`/`false`) cannot change.

&nbsp;

### `const`

*Example:* `<<const $favouriteFood as "Crisps">>`

The `<<const>>` action defines a special kind of variable - it is a variable whose value cannot be changed. This might seem contradictory at first glace - a variable must surely be able to vary?! - but this behaviour is very helpful when trying to keep track of so-called "magic numbers" in your game. For example, you might want to set the maximum number of health points that a player can have. At some point in development, that number might need to go up or down in order to balance the game's difficulty. Using a constant means that you can tweak the maximum number of health points throughout the game without having to find and adjust every single occurrence of a special number (a time-consuming endeavour that is likely to result in bugs).

&nbsp;

### `wait`

*Example:* `<<wait>>`

`<<wait>>` will put a chatterbox into a "waiting" state. This is used to break up sections of dialogue in non-singleton mode. You can tell a chatterbox to "un-wait" by calling `ChatterboxContinue()`.

?> In singleton mode this action does nothing because `<<wait>>` is implicitly and automatically called after every line of dialogue (so long as that dialogue isn't followed immediately by an `->` option).

?> `<<wait>>` is analogous to the `ChatterboxWait()` function.

&nbsp;

### `stop`

*Example:* `<<stop>>`

Tells a chatterbox to stop processing entirely. The chatterbox can be restarted by calling `ChatterboxJump()`.

?> `<<stop>>` is analogous to the `ChatterboxStop()` function.

&nbsp;

### `if`, `else` etc.

Branching logic is also written in between `<<` and `>>` too, such as `<<if visited("Home") == 4>>`. These are used to selectively execute parts of your YarnScript but aren't considered "actions" per se.

&nbsp;

## Functions

Chatterbox contains one custom function: `visited("NodeTitle")`. This function returns the number of times that a particular node has been visited. You can specifiy a node in a particular file by You can specifying the filename first, typing a `:` colon, and then specifying the node in that file. If you don't specify a file then Chatterbox will search in the current file for the desired node.

Powerful custom functions can be added to Chatterbox using the [`ChatterboxAddFunction()`](reference-configuration#chatterboxaddfunctionname-function) function. This is a global function and you only need to call it once per custom function. Custom functions can do anything that GML can do... because they're written in GML!

!> Custom functions must be defined before calling [`ChatterboxCreate()`](reference-chatterboxes#chatterboxcreatefilename-singletontext-localscope).

Custom functions can have parameters. Parameters should be separated by spaces and are passed into a script as an array of values in `argument0`. Custom functions can return values, and like Chatterbox variables, a function must return a number, a string, or a boolean `true` / `false`. A function can also return nothing (`undefined`).

?> You can use the `CHATTERBOX_CURRENT` read-only macro to get the chatterbox that is currently being processed. This is helpful when using `ChatterboxJump()` etc.

<!-- tabs:start -->

#### **GML**

```gml
function am_i_dead()
{
    return instance_exists(obj_player);
}


ChatterboxLoad("example.json");
ChatterboxAddFunction("AmIDead", am_i_dead);
```

#### **YarnScript**

```yarn
Am I dead?
<<if AmIDead("player")>>
    Yup. Definitely dead.
<<else>>
    Not today!
<<endif>>
```

<!-- tabs:end -->

This example shows how the script `am_i_dead()` is called by Chatterbox in an if statement. The value returned from `am_i_dead()` determines which text is displayed.

&nbsp;

## Custom Actions

A function that has been added to Chatterbox can further be executed as an action. This means you can execute any old code you like using Chatterbox; if you were so inclined you code write an entire game's logic from within YarnScript.

You can also define custom actions which are used in a similar way to in-built actions:

```yarn
What a beautiful evening, Amelia.
-> It'd be a shame if the Moon hid behind the clouds.
    <<HideTheMoon>>
-> The stars are so bright!
    <<FlickerStars>>
```

In this example, both `<<HideTheMoon>>` and `<<FlickerStars>>` are custom actions. 

There are three ways that custom actions can be used in Chatterbox; to swap between the different implementations set [`CHATTERBOX_DIRECTION_MODE`](reference-configuration?id=chatterbox_direction_mode) to one of the following (the default is option `1`):
- `0` Pass YarnScript actions as a raw string to a function, defined by `CHATTERBOX_DIRECTION_FUNCTION`
- `1` Treat actions as expressions
- `2` Treat actions as they were in version 1 (Python-esque function calls)

Mode `0` is the official recommendation from the Yarn team is that actions should pass a string into the game engine for manual interpretation. Chatterbox's implementation is that the function defined by `CHATTERBOX_DIRECTION_FUNCTION` is called when Chatterbox encounters an action, the first argument (`argument0`) for the function call being the text inside the action as a string. The intention is that you'd then parse that text and execute behaviour accordingly but... this sucks, it's a ton of work to actually do this, let's move on.

Mode `1` is the default Chatterbox behaviour:
1. Every custom action is expected to use GML-like syntax: functions are executed using their name followed by a comma-separated list of arguments e.g. `<<CustomFunction("string", "string with spaces", 3.14, true)>>`
2. Variables are referenced by using the standard dollar-prefixed token e.g. `<<TransmutateLead("Gold", $lead)>>`
3. You can also do basic operations, such as concatenation and basic arithmetic, in function arguments as you would expect in GML e.g. `<<ShowItem("BigAssSword" + $modifier)>>`

Mode `2` is provided as an easier-to-use alternative for larger teams where people are working with writers who are uncomfortable with GML-like function syntax. The examples above would be written like so:
1. `<<CustomFunction string "string with spaces" 3.14 true>>`
2. You can reference variables by using the standard dollar-prefixed token wrapped in `{` `}` curly brackets e.g. `<<TransmutateLead Gold {$lead}>>`
3. `<<ShowItem {"BigAssSword" + $modifier}>>`

&nbsp;

## Asynchronous Functions

This is an advanced power move! It's possible to create asynchronous function execution so that you can temporarily pause a chatterbox whilst something else happens in your game, such as running an animation or showing a cutscene. To do this we need three different components:
1. `CHATTERBOX_CURRENT` - Macro that contains a reference to the chatterbox that is currently being processed
2. `ChatterboxWait()` - Function that forces a chatterbox into a waiting state (pauses processing)
3. `ChatterboxContinue()` - Function that resumes processing for a chatterbox

<!-- tabs:start -->

#### **GML**

```gml
ChatterboxAddFunction("example", function(_duration)
{
    show_debug_message("Waiting chatterbox for " + string(_duration) + " seconds...");
    time_source_start(time_source_create(time_source_game, _duration, time_source_unit_frames,
    function(_chatterbox)
    {
        show_debug_message("...continuing chatterbox!");
        ChatterboxContinue(_chatterbox);
    },
    [CHATTERBOX_CURRENT]));
});
```

#### **YarnScript**

```yarn
Hello there, would you like to wait 5 seconds?
-> Nah...
-> Please.
    <<example(5)>>
Okey dokey.
```

<!-- tabs:end -->