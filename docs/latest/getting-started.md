# Getting Started

The Chatterbox library is built around little digital machines, called chatterboxes, that interpret narrative instructions stored in external files using a language called YarnScript. A chatterbox processes YarnScript and spits out text (called **content**) and sometimes a list of **options**. You can control these chatterbox machines by calling ["flow control" functions](reference-flow) using GML from your game, and this is how you communicate player decisions to chatterboxes.

Chatterbox itself does little more than hand you lines of text that you can draw to the screen, but you are entirely responsible for determining how to draw that text. Equally, chatterboxes do no processing unless you specifically call a function to tell them to do something. Chatterbox execution is "synchronous" - when you tell a chatterbox to do something, it'll do it immediately. You can build functionality to make some behaviour asynchronous if you'd like but that is not a native feature.

Chatterbox offers a lot of ways to [configure](reference-configuration) the way it works so that it can adapt to varied use cases, and has many functions available to otherwise interact with YarnScript data. This guide is intended to demonstrate basic usage for simple visual novel-style dialogue delivery which is generally applicable across most games.

&nbsp;

### YarnScript

As mentioned, chatterboxes read instructions written in a language called YarnScript. You can find more information about YarnScript in [here](concept-yarn-script) in Chatterbox's documentation. What follows is a brief primer on basic usage to get you up and running.