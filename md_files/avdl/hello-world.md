# avdl - Hello, World!

This page will show a "Hello, World!" program made in `avdl`.
It will explain all the basic details to show all skills
needed to make a very basic game.

Back to main page: <a class="menu" href="@ROOT@/avdl.html">avdl</a>

---

## Aim

The "Hello, World!" program will display a triangle, of pale violet colour,
that keeps rotating. The aim is to show a very simple program using `avdl`.

It will explain some basic concepts like how to:

* create a new world
* update the world's state
* create new meshes, load them and give them a colour

---

## Create a world

Create a file named `hello-world.dd`, and open it with a text editor.

The first thing needed, is create a new world that will host our
triangle. To do that, we need to create a new `class`, that is a
subclass of `dd_world` (`avdl`'s world class).

The syntax to create a class is as follows:

	(class -classname- -subclass- -declarations-)

Where:

* -classname- : The name of the class. Can be anything.
* -subclass-  : The subclass of the class we are creating.
* -declarations- : All the data that the new class has (variables, functions, etc)

Using that information, let's create a world called "HelloWorld":

	(class HelloWorld dd_world
		(group

		(def dd_meshColour triangle)
		(def float rotation)

		(function void create (group))
		(function void update (group))
		(function void draw (group))
		(function void clean (group))

		)
	)

Let's break this in parts and explain what it does.

	(class HelloWorld dd_world
		(group

This creates a new world called `HelloWorld`, which is a subclass of `dd_world`.
The `group` command is used to pass multiple expressions when one is expected.
In this case, multiple variables and function declarations are passed, so we
group them together.

		(def dd_meshColour triangle)
		(def float rotation)

The command `def` is used to declare a variable. In this case it is used
to declare that these variables belong in the `HelloWorld` world. It's signature
is this:

	(def -vartype- -varname-)

Where:

* -vartype- : The variable type. Could be a primitive like `int`, `float`, or another class.
* -varname- : The variable name. Can be anything.

The `dd_meshColour` is an internal class that creates a mesh with a shape and vertex colours.
So the lines above create a mesh with the name `triangle`, and a floating number that tracks
constant rotation, with the name `rotation`.

		(function void create (group))
		(function void update (group))
		(function void draw (group))
		(function void clean (group))

These are functions that `avdl` calls when specific criteria is met.
The command `function` has the following signature:

	(function -type- -name- -arguments-)

Where:

* -type- : The function type. Can be a primitive like `int`, `float` or `void`.
* -name- : The function name. Can be anything.
* -arguments- : The arguments of that function. Not useful for this tutorial.

So the above lines declare a few functions that return nothing (`void`) and have no arguments
(empty `group` command).

---

## Implement the world's initialisation

In this part, the world needs to have a defined behaviour.
What does the `triangle` mesh look like? What colour is it?
What kind of rotation does it do and how fast?

To do this, the world's functions need to be implemented,
starting with the `create` one. This function will run
once when the world is marked to be created, and looks like this:

	(class_function HelloWorld void create (group)
		(group

		(dd_clearColour 0.13 0.13 0.13 1)

		(= this.rotation 0)

		(this.triangle.set_primitive DD_PRIMITIVE_TRIANGLE)
		(this.triangle.set_colour 0.8 0.6 1)

		)
	)

The command `class_function` is used to implement a function belonging to a class.
It's signature is this:

	(class_function -classname- -type- -name- -arguments- -statements-)

Where:

* -classname-  : The name of the class the function belongs to.
* -type-       : The return type of the function. Can be any primitive (`int`, `float`, `void`, etc).
* -name-       : The name of the function.
* -arguments-  : The arguments of that function. Not useful for this tutorial.
* -statements- : The statements that are executed, when the function is run.

With this information, let's look at the first two lines:

	(class_function HelloWorld void create (group)
		(group

These implement the function `create` belonging to class `HelloWorld`,
which returns `void` and has no arguments. The second `group` command is for
declaring the statements inside of it.

		(dd_clearColour 0.13 0.13 0.13 1)

The command `dd_clearColour` sets the colour that the window is using to clear
itself. If nothing is drawn, the whole screen will have that colour. It
takes 4 float numbers as arguments, that define the values red, green, blue and
alpha.

		(= this.rotation 0)

This sets the initial rotation to `0`.

		(this.triangle.set_primitive DD_PRIMITIVE_TRIANGLE)
		(this.triangle.set_colour 0.8 0.6 1)

These two lines define what the `triangle` mesh looks like.

The command `set_primitive` gives it a shape that is pre-defined
by `avdl`. Possible values at the moment are `DD_PRIMITIVE_TRIANGLE`,
`DD_PRIMITIVE_RECTANGLE` and `DD_PRIMITIVE_BOX`.

The command `set_colour` gives a colour to the mesh's shape.
It takes three float numbers as input, that represent red,
green and blue values.

> Important: The mesh's shape has to have been defined **before** it
is given a colour.

---

## Implement the world's update functionality

It gets easier from here, now the world `update` function needs
to be implemented. This is run once per frame, and takes care
of updating the world's state. It looks like this:

	(class_function HelloWorld void update (group)
		(group

		(= this.rotation (+ this.rotation 1))

		(if (>= this.rotation 360)
			(= this.rotation (- this.rotation 360))
		)

		)
	)

Let's break it down again:

	(class_function HelloWorld void update (group)
		(group

Like before, this defines the implementation of function `update`, belonging
to class `HelloWorld`, which returns `void` and has no arguments.

		(= this.rotation (+ this.rotation 1))

This part, increases the `rotation` value by `1` every frame.
This like can be interpreted as `this.rotation = this.rotation + 1`.

		(if (>= this.rotation 360)
			(= this.rotation (- this.rotation 360))
		)

This part is only there to wrap around the value of `rotation`,
so when it goes above `360`, it will go back to `0` and continue
increasing infinitely. Given our rotation will be a full circle,
this change won't be visible on the screen.

---

## Implement the world's draw functionality

Next is the world's `draw` function. What does the world look
like? Where is the "camera" looking from? The code looks like
this:

	(class_function HelloWorld void draw (group)
		(group

		(dd_translatef 0 0 -5)

		(dd_rotatef this.rotation 0 0 1)

		(this.triangle.draw)

		)
	)

Let's break it down:

	(class_function HelloWorld void draw (group)
		(group

As before, this implements the function `draw` of class `HelloWorld`,
which returns `void` and has no arguments.

		(dd_translatef 0 0 -5)

The default "camera" is in the center of the world, looking
at the `-Z` axis. So to position something directly in front
of the camera, we need to move what we want to draw in the same
direction, in this case, `5` points in the `-Z` axis.

		(dd_rotatef this.rotation 0 0 1)

This is where the rotation comes in. This line will rotate
any object that we draw after it `this.rotation` degrees around the `Z`
axis.

		(this.triangle.draw)

The last line, simply draws the `triangle` mesh in the
current position (influenced by the translation and rotation
above). This will draw the triangle in the middle of the screen.

---

## Implement the world's clean functionality

This part is temporary, and is meant to be removed
in a future version of `avdl`. Until then, the `clean` function has
to be implemented as an empty function like this:

	(class_function HelloWorld void clean (group) (group))

The `avdl` compiler then knows how to add the right functionality
to free all resources that this world was using.

---

## Set the project's settings

Before this project is complete, we need to define the `dd_gameInit` function.
This is a function that runs when the game is first started, before a world is
shown on the screen. In fact, this defines which world should be shown on the
screen by default:

	(function void dd_gameInit (group)
		(group

		(dd_setGameTitle "Hello World - avdl")

		(dd_world_set_default HelloWorld)

		)
	)

Let's break it up:

	(function void dd_gameInit (group)
		(group

This defines the function `dd_gameInit` that returns `void` and
takes no arguments.

		(dd_setGameTitle "Hello World - avdl")

The command `dd_setGameTitle` will determine the text that appears
on top of a window. On some operating systems, this is always visible,
but on others it might not. So it's good to keep in mind that not
all users will see this.

		(dd_world_set_default HelloWorld)

This will define the default world, the one that will appear on the screen
as soon as everything is loaded as expected. We simply pass it the name
of the class created above `HelloWorld`, and `avdl` will take care of the rest.

---

## Final finish

That's it. The last part left is to compile the above file into an executable.
This can be done with the following command:

	avdl hello-world.dd

Once this is done, it will create an executable called `game` in the same directory.
By running that, a window should pop-up with a rotating triangle with a pale violet colour.

You can find this file in the `avdl` repository, under `samples/hello-world/hello-world.dd` here:
<a class="button" href="https://github.com/tomtsagk/avdl">Github</a>

---

## What's next?

The `avdl` language is still under active development.
As it evolved, more tutorials will be added here.

Until then, move back to the main page:

<a class="menu" href="@ROOT@/avdl.html">avdl</a>
