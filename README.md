HYPEDynamicColorPalettes
========================
Using HYPE and Processing, this is an example of how I am able to extract color palettes from images on the fly.

What is happening?
==================
Essentially what is happening is I am loading a source image into a HPixelColorist, then grabbing random colors from that image based on the mouse position and a radius to extend from. Those colors get saved into an HColorPool which is then applied to my HShapes.

How to use
==========
Download build folder, and run build.pde in Processing.
Use the key commands and mouse to play around with colors.

KEY Commands
============
= & -, increase & decrease number of shapes in the grid
y & t, increase & decrease number of colors in palette
i & u, increase & decrease color picking radius
p & o, increase & decrease anchor offset of shapes
up & down, increase & decrease shape size
left & right, increase & decrease opacity of colors
[ & ] cycle through svgs
; & ' cycle  through color palette images

h, toggle HUD
j, toggle showing the brush layer (hide to see your art)
k, toggle showing color palette
l, toggle color palette lock (unlock to pick new colors, lock to set colors)

c, clear the background
f, fill the background with mouse color
s, save the high quality image

