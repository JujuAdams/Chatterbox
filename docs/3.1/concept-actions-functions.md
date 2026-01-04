# Actions and Functions

ChatterScript allows for flow control and the execution of external code by using its "action" syntax. Actions in ChatterScript are commands written in between `<<` and `>>` like so:

```yaml
title: FlowerSeedShelf
---

<<declare $flowerSeeds to 0>>
<<const $maximumFlowerSeeds to 3>>

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

*Example*: `<<jump Christina.chatter:GenericGreeting>>`

*Example*: `<<jump $nodeTitleStoredInAVariable>>`

The `<<jump>>` action causes a chatterbox to immediately swap execution to another node in a ChatterScript file. Execution will start from the top of the new node. If you `<<jump>>` back to the old node then you will start execution from the top of the node. You can specify a particular ChatterScript file to jump to by specifying the filename first, typing a `:` colon, and then specifying the node in that file. If you don't specify a file then Chatterbox will search in the current file for the desired node. `<<jump>>` can be used to jump to a node stored in a variable by referencing the variable as the destination node title.

&nbsp;

### `hop` and `hopback`

*Example:* `<<hop WistfulMemories>>` and later `<<hopback>>`

*Example:* `<<hop TangentialConversations.chatter:NatureOfBeing>>` and later `<<hopback>>`

*Example*: `<<hop $nodeTitleStoredInAVariable>>` and later `<<hopback>>`


`<<hop>>` operates similarly to `<<jump>>` (see above). `<<hop>>` differs from `<<jump>>` insofar as you can hop back into a node from where you hopped out. This operates on a stack such that calling `<<hop>>` twice and then calling `<<hopback>>` twice will result in a chatterbox being at the exact same position that the first `<<hop>>` was called.

!> It is not possible to save or load the hop stack. Do not rely on the hop stack for tracking important game logic that may need to persist between game sessions.

&nbsp;

### `declare`

*Example:* `<<declare $favouriteFood = "Cheesecake">>`

*Example:* `<<declare $favouriteFood to "Cheesecake">>`

This action instructs Chatterbox to declare a variable and to give it a default value.

&nbsp;

### `set`

*Example:* `<<set $favouriteFood = "Curry">>`
    
*Example:* `<<set $favouriteFood to "Curry">>`

Sets the value of a variable, plain and simple. The datatype of a variable (string, number, or boolean `true`/`false`) cannot change.

&nbsp;

### `const`

*Example:* `<<const $favouriteFood to "Crisps">>`

The `<<const>>` action defines a special kind of variable - it is a variable whose value cannot be changed. This might seem contradictory at first glace - a variable must surely be able to vary?! - but this behaviour is very helpful when trying to keep track of so-called "magic numbers" in your game. For example, you might want to set the maximum number of health points that a player can have. At some point in development, that number might need to go up or down in order to balance the game's difficulty. Using a constant means that you can tweak the maximum number of health points throughout the game without having to find and adjust every single occurrence of a special number (a time-consuming endeavour that is likely to result in bugs).

&nbsp;

### `wait`

*Example:* `<<wait>>`

`<<wait>>` will put a chatterbox into a "waiting" state. This is used to break up sections of dialogue in non-singleton mode. You can tell a chatterbox to "un-wait" by calling `ChatterboxContinue()`.

If the chatterbox is running in fast-forward mode (see `ChatterboxFastForward()`) then a standard `<<wait>>` action will be ignored. To always wait, even when in fast-forward mode, please use `<<forcewait>>`.

You can also specify a name in a wait command. This name is then used to filter continue commands when calling `ChatterboxContinue()`. For example, the command `<<wait timer>>` can only be continued by calling `ChatterboxContinue(chatterbox, "timer")`. A wait command with no name (`<<wait>>`) is treated as having an empty string `""` as a name.

?> In singleton mode this action does nothing because `<<wait>>` is implicitly and automatically called after every line of dialogue (so long as that dialogue isn't followed immediately by an `->` option).

?> `ChatterboxWait()` can be called from a Chatterbox action to cause a chatterbox to forcibly wait. Doing so will ignore fast-forward mode (`ChatterboxWait()` is analogous to `<<forcewait>>`).

&nbsp;

### `stop`

*Example:* `<<stop>>`

Tells a chatterbox to stop processing entirely. The chatterbox can be restarted by calling `ChatterboxJump()`.

?> `<<stop>>` is analogous to the `ChatterboxStop()` function.

&nbsp;

### `if`, `else` etc.

Branching logic is also written in between `<<` and `>>` too, such as `<<if visited("Home") == 4>>`. These are used to selectively execute parts of your ChatterScript but aren't considered "actions" per se.

&nbsp;

### `forcewait`

*Example:* `<<forcewait>>`

`<<forcewait>>` will put a chatterbox into a "waiting" state regardless of whether a chatterbox is fast-forwarding or not. You can tell a chatterbox to "un-wait" by calling `ChatterboxContinue()` as you would with the `<<wait>>` action.

You can also specify a name in a force wait command. This name is then used to filter continue commands when calling `ChatterboxContinue()`. For example, the command `<<forcewait timer>>` can only be continued by calling `ChatterboxContinue(chatterbox, "timer")`. A force wait command with no name (`<<forcewait>>`) is treated as having an empty string `""` as a name.

?> `<<forcewait>>` is analogous to the `ChatterboxWait()` function.

&nbsp;

### `fastmark`

*Example:* `<<fastmark>>`

`<<fastmark>>` will not pause a chatterbox but it will disable fast-forward mode. Any content after the `<<fastmark>>` action will still be displayed but any content between triggering fast-forward mode and `<<fastmark>>` will not appear. If a chatterbox is not fast-forwarding then this action does nothing.

&nbsp;

## Functions

### `visited`

Chatterbox includes a `visited()` function which returns the number of times a node has been entered.

```chatterscript
<<if visited("GoToCity")>>
    We have gone to the city before!
<<endif>>
```

You may skip providing the node name to get the number of times the current node has been entered.

```chatterscript
We have visted this node {visited()} times before.
```

### `localCounter`

This special ChatterScript function will increment a counter and return the new value. The counter is unique to the filename and node, and is further unique based on the identifier i.e. two `localCounter()` calls with the same identifier in two different nodes will use two counters internally.

```chatterscript
You've seen this line of dialogue {localCounter("apple")} times.
```

Local counters are further saved and loaded by `ChatterboxVariablesExport()` and `ChatterboxVariablesImport()`.

### `once`

Shorthand for `localCounter("identifier") == 1`.

```chatterscript
<<if once("greeting")>>
    You are an unfamiliar face. Greetings.
<<else>>
    Hello again friend!
<<endif>>
```

### `optionChosen`

Chatterbox also includes the `optionChosen()` function. This works similarly to `visited()` but can only be used in the condition for an option, like so:

```chatterscript
How can I help?
-> Can I buy some green eggs please? <<if !optionChosen()>>
    No... This is a stationery shop.
-> Do you have any ham for sale? <<if !optionChosen()>>
    Huh? We mostly sell birthday cards.
```

Using `optionChosen()` outside of an option condition is invalid and will throw an error. What options have been chosen is **not** intended to persist between gameplay sessions and is **not** included in the data returned by `ChatterboxVariablesExport()`. If you want to track which options have been chosen, you should use `localCounter()` above.

### Custom Functions

Other custom functions can be added to Chatterbox using the [`ChatterboxAddFunction()`](reference-configuration#chatterboxaddfunctionname-function) script. Much like custom actions, custom functions can have parameters. Custom functions should be defined before calling [`ChatterboxCreate()`](reference-chatterboxes#chatterboxcreatefilename-singletontext-localscope).

<!-- tabs:start -->

#### **GML**

```gml
ChatterboxLoad("example.json");
ChatterboxAddFunction("AmIDead", am_i_dead);
```

#### **ChatterScript**

```chatterscript
Am I dead?
<<if AmIDead("player")>>
    Yup. Definitely dead.
<<else>>
    No, not yet!
<<endif>>
```

<!-- tabs:end -->

This example shows how the script `am_i_dead()` is called by Chatterbox in an if statement. The value returned from `am_i_dead()` determines which text is displayed.

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

#### **ChatterScript**

```chatterscript
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

A function that has been added to Chatterbox can further be executed as an action. This means you can execute any old code you like using Chatterbox; if you were so inclined you code write an entire game's logic from within ChatterScript.

You can also define custom actions which are used in a similar way to in-built actions:

```chatterscript
What a beautiful evening, Amelia.
-> It'd be a shame if the Moon hid behind the clouds.
    <<HideTheMoon>>
-> The stars are so bright!
    <<FlickerStars>>
```

In this example, both `<<HideTheMoon>>` and `<<FlickerStars>>` are custom actions. 

There are three ways that custom actions can be used in Chatterbox; to swap between the different implementations set [`CHATTERBOX_ACTION_MODE`](reference-configuration?id=chatterbox_action_mode) to one of the following (the default is option `1`):
- `1` Treat actions as expressions
- `2` Treat actions as they were in version 1 (Python-esque function calls)

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

The following example assumes [`CHATTERBOX_ACTION_MODE`](reference-configuration?id=chatterbox_action_mode) has been set to `1` and [`CHATTERBOX_FUNCTION_ARRAY_ARGUMENTS`](reference-configuration?id=chatterbox_function_array_arguments) has been set to `true`.

<!-- tabs:start -->

#### **GML**

```gml
ChatterboxAddFunction("example", function(_argumentArray)
{
    ChatterboxWait(CHATTERBOX_CURRENT);
    show_debug_message("Waiting chatterbox for " + string(_argumentArray[0]) + " frames...");
    time_source_start(time_source_create(time_source_game, _argumentArray[0], time_source_units_frames,
    function(_chatterbox)
    {
        show_debug_message("...continuing chatterbox!");
        ChatterboxContinue(_chatterbox);
    },
    [CHATTERBOX_CURRENT]));
});
```

#### **ChatterScript**

```chatterscript
Hello there, would you like to wait 5 seconds?
-> Nah...
-> Please.
    <<example(300)>>
Okey dokey.
```

<!-- tabs:end -->
