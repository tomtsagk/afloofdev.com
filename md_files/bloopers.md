# Bloopers

Things that sometimes didn't go as planned ...

---

##checkers error

<img src="/images/icon_bloopers_checkers.png" style="width:400px" alt="Checkers error icon"/>

i was experimenting with giving different colors to each vertex.
then i decided to edit the colors to give some sort of "fake lighting" on them. one thing led to another,
and when i compiled and run the game i got a checkers thingy! no that's not a texture!

2016.04.03

---

##undefined behaviour

*watch on [youtube](https://www.youtube.com/watch?v=UhYWDLUXIVA)*

here i was trying to make a font. but i did something wrong (with pointers obviously) which
brought some undefined behavior. i'm not sure why visually it's behaving like this, but i loved it!

2016.04.03

---

##manual matrix rotation

*watch on [youtube](https://www.youtube.com/watch?v=tyU7V07syzs)*

my inner perfectionist wanted to do matrix rotation manually (just so I could understand what is happening).
i learned how to do euler's rotation for 1 axis. tried to study quaternions. gave up (for now).
then a wild idea came, "why not use euler's rotation on multiple axis?". well, the result is what happened on the video. 
at least my curiosity is satisfied.

2016.04.03

---

##undefined shader colors

*watch on [youtube](https://www.youtube.com/watch?v=hn-dcyHnp40)*

the only thing i did was to supply to the shaders (that expect colors) an uninitialized pointer.
i was expecting that it would be random colors (like in the video) but I thought it wouldn't change. 

2016.04.03
