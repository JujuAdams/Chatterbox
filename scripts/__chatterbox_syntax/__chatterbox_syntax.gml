/// This is a slightly edited copy of the YarnSpinner Quick Refence Guide (fetched on 2019/04/18):
///     https://github.com/thesecretlab/YarnSpinner/blob/master/Documentation/YarnSpinner-Dialogue/Yarn-Syntax.md
/// (YarnSpinner is the Unity implementation of Yarn.)
/// 
/// Chatterbox is a full implementation of the Yarn scripting language. However, Chatterbox does slightly extend its functionality,
/// adding more control to variable handling. This enables convenient direct access of GML variables from inside the dialogue script.
/// Please see the "Variables & Conditionals" section for more information. Chatterbox additionally allows redirects and options to
/// point to nodes found in other source files.
/// 
/// 
/// 
/// 
/// 
/// YARN QUICK REFERENCE
/// 
/// This document is intended to act as a comprehensive and concise reference for Yarn syntax and structure, for use by programmers
/// and content creators. It assumes a working knowledge of modern programming/scripting languages. For a more thorough explanation
/// of Yarn usage, see the General Usage Guide
/// 
/// 
/// 
/// -- Nodes --
/// Nodes act as containers for Yarn script, and must have unique titles. The script in the body of a node is processed line by line.
/// A node's header contains its metadata - by default, Yarn only uses the title field, but can be extended to use arbitrary fields.
/// 
///     title: ExampleNodeName
///     tags: foo, bar
///     ---
///     
///     Yarn content goes here.
///     This is the second line.
///     
///     ===
/// 
/// A script file can contain multiple nodes. In this case, nodes are delineated using three equals (=) characters.
/// Additionally, Yarn can check if a node has been visited by calling visited("NodeName") in an if statement
/// (i.e. <<if visited("NodeName") == true>>).
/// 
/// 
/// -- Links Between Nodes --
/// Nodes link to other nodes through options. An option is composed of a label (optional) and a node name separated by a vertical
/// bar (|), like so:
/// 
///     [[This is a link to a node.|DestinationNode]]
/// 
/// If a node link with no label is provided Yarn will automatically navigate to the linked node:
/// 
///     [[DestinationNode]]
/// 
/// Chatterbox adds the ability to target nodes in other files:
/// 
///     [[A link to a node in another file.|TheOtherFile.json:DestinationNode]]
/// 
/// The name of the file (with that file's extension!) comes first, followed by a colon (":"), followed by the name of the node.
/// This syntax also works for redirects too:
/// 
///     [[TheOtherFile.json:DestinationNode]]
/// 
/// 
/// 
/// -- Menu Syntax --
/// Shortcut options allow for small branches in Yarn scripts without requiring extra nodes. Shortcut option sets allow for an arbitrary
/// number of sub-branches, but it's recommended that users stick to as few as possible for the sake of script readability.
/// 
///     Mae: What did you say to her?
///     -> Nothing.
///         Mae: Oh, man. Maybe you should have.
///     -> That she was a jerk.
///         Mae: Hah! I bet that pissed her off.
///         Mae: How'd she react?
///         -> She didn't.
///             Mae: Booooo. That's boring.
///         -> Furiously.
///             Mae: That's what I like to hear!
///     Mae: Anyway, I'd better get going.
/// 
/// Additionally, shortcut options can utilize conditional logic, commands and functions (detailed below), and can include standard node
/// links. If a condition is attached to a shortcut option, the option will only appear to the reader if the condition passes:
/// 
///     Bob: What would you like?
///     -> A burger. <<if $money > 5>> 
///         Bob: Nice. Enjoy!
///         [[AteABurger]]
///     -> A soda. <<if $money > 2>>
///         Bob: Yum!
///         [[DrankASoda]]
///     -> Nothing.
///         Bob: Okay.
///     Bob: Thanks for coming!
/// 
/// 
/// 
/// -- Option Syntax --
/// Multiple labeled node links on consecutive lines will be parsed as a menu. Example:
/// 
/// [[Option 1|Node1]]
/// [[Option the Second|Node2]]
/// [[Third Option|Node3]]
/// 
/// 
/// 
/// -- Variables & Conditionals --
/// 
/// Declaring and Setting Variables:
/// This statement serves to set a variable's value. No declarative statement is required; setting a variable's value brings it into existence.
/// 
///     <<set $ExampleVariable to 1>>
/// 
/// Variables in Chatterbox can have their scope controlled by using prefixes:
/// 
///     <<set global.meaning to 42>>        This will set the GM global variable "global.meaning" to the value 42.
///     <<set local.variable to 13>>        This will set the GM instance variable "shenanigans" to the value 13.
///     <<set internal.organelle to 7>>     This will set the internal Chatterbox variable "organelle" to the value 7.
/// 
/// Internal Chatterbox variables are, in reality, key:value pairs stored in a global ds_map. You can access this ds_map via
/// the CHATTERBOX_VARIABLES_MAP macro, found in __chatterbox_config().
/// 
/// The Yarn specification states that all variables must begin with a $-sign. Whilst Chatterbox expands upon Yarn variables, it does still fully
/// support $-prefixed variables. The scope of $-prefixed variables is determined by CHATTERBOX_NAKED_VARIABLE_SCOPE, found in __chatterbox_config().
/// By default, a variable that starts with a $-sign is scoped to be an internal Chatterbox variable.
/// 
///     <<set yarnful to "okey dokey">>     This (by default) sets the internal Chatterbox variable "yarnful" to the value "okey dokey"
/// 
/// If a variable has no prefix then its scope is determined by CHATTERBOX_NAKED_VARIABLE_SCOPE, found in __chatterbox_config().
/// By default, a variable with no prefix is scoped to be an internal Chatterbox variable.
/// 
///     <<set noPrefixForMe to "oh ok">>    This (by default) sets the internal Chatterbox variable "noPrefixForMe" to the value "oh ok"
/// 
/// 
/// 
/// Variable Types:
/// There are four different types of variable in Yarn: strings, floating-point numbers, booleans, and null.
/// 
/// Yarn will automatically convert between types. For example:
/// 
///     <<if "hi" == "hi">>
///         The two strings are the same!
///     <<endif>>
/// 
///     <<if 1+1+"hi" == "2hi">>
///         Strings get joined together with other values!
///     <<endif>>
/// 
/// If/Else Statements:
/// Yarn supports standard if/else/elseif statements.
/// 
///     <<if "hi" == "hi">>
///         The two strings are the same!
///     <<endif>>
///     <<if $variable == 1>>
///         Success!
///     <<elseif $variable == "hello">>
///         Success...?
///     <<else>>
///         No success. :(
///     <<endif>>
/// 
/// Supported operators:
/// 
///     WORD  |  SYMBOL
///     ------+--------
///           |    !
///           |    +
///           |    -
///           |    *
///           |    /
///       Assignemnt
///     to    |    =
///           |   +=
///           |   -=
///           |   *=
///           |   /=
///       Comparison
///     and   |   &&
///     le    |    <
///     gt    |    >
///     or    |   ||
///     leq   |   <=
///     geq   |   >=
///     eq    |   ==
///     is    |   ==
///     neq   |   !=
///     not   |    !
/// 
/// NB: For compatibility with other Yarn files, "`", "&", and "|" are also supported.
/// 
/// 
/// 
/// -- Commands and Functions --
/// By default, Chatterbox includes a visited() function, used to check whether a node has been entered.
/// 
///     <<if visited("GoToCity")>>
///         We have gone to the city before!
///     <<endif>>