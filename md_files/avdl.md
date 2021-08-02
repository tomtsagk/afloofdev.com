# avdl

This is a high level programming language, to create 3D games.

The idea behind it, is that games are described in
an abstract way. It then becomes the compiler's responsibility
of converting that to an actual, executable video game for
each platform.

To get an idea of what this language has achieved so far,
here are some games made with it:

<a class="menu" href="@ROOT@/games/rue.html">Rue</a> |
<a class="menu" href="@ROOT@/the_king_is_gone.html">The king is gone</a> |
<a class="menu" href="@ROOT@/shuffled_nightmares.html">Shuffled Nightmares</a>

---

## Syntax

`avdl` is using a syntax that consists of symbolic expressions.
These are in place to ensure the language is explicit on what
it is describing. They also help simplify the syntax,
so users can focus on learning about the language's new features.

This is an example of printing the text `Hello, World!` in avdl:

	(echo "Hello, World!")

The trick of what makes this language flexible, is that each
symbolic expression, can contain either primitive data (integers,
floats, text, etc) or another symbolic expression.

This is an example of adding two numbers, and assigning the result
to the variable `x`:

	(= x (+ 2 7))

---

## Where do I start?

Before diving into the language itself, there is a bit of theory.
The introduction below shows how the language works behind the scenes
and what kind of data it expects from the programmer, to properly
understand what the game is intended to look like.

<a class="menu" href="@ROOT@/avdl/introduction.html">Introduction</a>

For those eager enough to dive in, below is a tutorial of how to
make a "Hello, World!" program in `avdl`. It displays a rotating
triangle, which is pale violet in colour.

<a class="menu" href="@ROOT@/avdl/hello-world.html">avdl - Hello, World!</a>

---

## Find the source code on

<a class="button" href="https://notabug.org/tomtsagk/avdl">NotABug</a>
