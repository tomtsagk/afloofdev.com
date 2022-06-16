# avdl - Introduction

This page will explain the basic concepts before someone
can start developing games using the `avdl` programming
language.

Back to main page: <a class="menu" href="/avdl">avdl</a>

---

## Worlds

The `avdl` language is divined into separate entities
called "worlds". Each world represents a 3D environment that
contains it's own data, and is responsible for drawing itself
on the screen.

In typical usage, a programmer is meant to create several
of those worlds, and pass them to `avdl` at desired times,
so they become visible on the screen.

As an example, a world can represent the main menu
of a game, and another world can represent the game itself.
When a button is pressed on the main menu, it fires off a
signal to `avdl` to show the world containing the game.

Each world has several functions, which `avdl` fires depending on
certain criteria:

* `create` : Fired once, as soon as possible after the new world
	is signaled to be created, before assets are loaded.
* `onload` : Fired once, after assets are loaded. Will always
	run after `create`.
* `update` : Fired once per frame.
* `resize` : Fired once, every time the game window size changes.
* `draw`   : Fired whenever something needs to be drawn on the screen.
	Could be slower or faster than once per frame.

On top of those, there are some similar functions that handle input:

* `key_input` : Fired once for every button that is pressed on the keyboard.
	Does not support controllers (yet).
* `mouse_input` : Fired once when a mouse button is pressed, and once when it's
	released.

---

## The entry point

In `avdl`, the first function that is run is called `dd_mainInit`.
That's the best place to set one-time configuration, like the window title.

At a minimum, the default world needs to be declared. This will be the world
that appears on the screen when the game is run. It looks like this:

	(dd_world_set_default nameOfMyDefaultWorld)

---

## What's next?

This is all the important theory of how `avdl` works.
Using this knowledge, the next step is to dive into the action,
and learn how to make a "Hello, World!" program:

<a class="menu" href="/avdl/hello-world.html">avdl - Hello, World!</a>

Otherwise, move back to the main page:

<a class="menu" href="/avdl">avdl</a>
