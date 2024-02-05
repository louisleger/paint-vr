# paint-vr

This project was done with a good highschool friend of mine Ixil Miniussi, who uploaded this project to github that we worked on for several months from January to June 2019. 
[Demonstration Video](https://www.youtube.com/embed/_4Z0W0Z2gyc).

# What is it
Paint VR is a homemade VR pictionary clone. The goal is for players to guess, by looking on the laptop screen, what the painter is drawing (inside the VR world.)
This is made doubly funny by the sometimes inacurrate tracking of the player's head and paintbrush. However, depsite being inaccurate, the tracking is still the impressive part of this project.

## Context
Done by two highschool students as a first-time coding project for the baccalauréat, the game runs on two programs coded in [https://processing.org/](Processing).

### paint_pc
Tracks the player's head and brush (a stick with a flashy inflatable balloon at its tip) through two identical webcams installed side by side.
Through a blob tracking algorithm, both webcams guess the necessary positions on their screen. Then, using the disparity between both webcam coordinates and some mathematics, we can deduce the distance from the screen of these elements.
For instance, a closer element will appear in vastly different locations within both webcams, whereas something far off will have similar coordinates between webcams.

Once we have an estimate x, y, and z position, we send it to the phone algorithm using OSC (Open Sound Control, a repurposed Processing library that can send data wirelessly).

## paint_vr
Receives the coordinates and displays the world for the player, the paint brush and camera move in 3d space accordingly. The player has access to 3 colored paint buckets which they can use to draw on the canvas. They can also change themes which will reroll a drawing prompts and skybox.

